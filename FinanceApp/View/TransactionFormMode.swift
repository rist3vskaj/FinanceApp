import SwiftUI

enum TXFormMode: Equatable {
    case create
    case edit(Transaction)
}

struct CategoryPickerView: View {
    @Binding var selection: Category
    let categories: [Category]
    
    var body: some View {
        List(categories.isEmpty ? [Category(id: 0, name: "No categories available", isIncome: false, emoji: "⚠️")] : categories) { c in
            HStack {
                Text(c.name)
                Spacer()
                if c.id == selection.id {
                    Image(systemName: "checkmark")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selection = c
            }
        }
        .navigationTitle("Статья")
    }
}

struct TransactionFormView: View {
    @EnvironmentObject private var txService: TransactionsService
    @EnvironmentObject private var accountsService: BankAccountsService
    @EnvironmentObject private var categoriesService: CategoriesService
    @EnvironmentObject private var networkUIUtil: NetworkUIUtil
    @Environment(\.dismiss) private var dismiss
    
    let mode: TXFormMode
    let direction: Direction
    
    @State private var account: BankAccount?
    @State private var categories: [Category] = []
    @State private var selectedCat: Category = Category(id: 0, name: "…", isIncome: false, emoji: " ")
    @State private var previousCategoryId: Int? // Track the previously selected category ID
    @State private var amountText: String = ""
    @State private var date: Date = Date()
    @State private var comment: String = ""
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    
    private var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section {
                        NavigationLink {
                            CategoryPickerView(selection: $selectedCat, categories: categories)
                        } label: {
                            HStack {
                                Text("Статья")
                                Spacer()
                                Text(selectedCat.name.isEmpty ? "—" : selectedCat.name)
                                    .foregroundColor(selectedCat.name.isEmpty ? .secondary : .primary)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        HStack {
                            Text("Сумма")
                            TextField("0\(decimalSeparator)00", text: $amountText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: amountText) { new in
                                    let allowed = CharacterSet.decimalDigits
                                        .union(CharacterSet(charactersIn: decimalSeparator))
                                    var filtered = new.filter { char in
                                        String(char).rangeOfCharacter(from: allowed) != nil
                                    }
                                    
                                    let parts = filtered.components(separatedBy: decimalSeparator)
                                    if parts.count > 2 {
                                        filtered = parts[0] + decimalSeparator + parts[1] + parts.dropFirst(2).joined()
                                    }
                                    if filtered != new {
                                        amountText = filtered
                                    }
                                }
                        }
                        
                        HStack {
                            Text("Дата")
                            Spacer()
                            DatePicker(
                                "",
                                selection: $date,
                                in: ...Date(),
                                displayedComponents: .date
                            )
                            .labelsHidden()
                            .datePickerStyle(.compact)
                        }
                        
                        HStack {
                            Text("Время")
                            Spacer()
                            DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $comment)
                                .frame(minHeight: 80)
                            if comment.isEmpty {
                                Text("Комментарий")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                    
                    if case .edit(let tx) = mode {
                        Section {
                            Button("Удалить операцию", role: .destructive) {
                                Task {
                                    do {
                                        try await networkUIUtil.perform {
                                            try await txService.deleteTransaction(id: tx.id)
                                        }
                                        dismiss()
                                    } catch {
                                        print("Delete error: \(error)")
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle(
                    mode == .create
                        ? (direction == .income ? "Мои доходы" : "Мои расходы")
                        : "Редактировать операцию"
                )
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Отмена") { dismiss() }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(mode == .create ? "Создать" : "Сохранить") {
                            let amtValid = !amountText.isEmpty && Decimal(string: amountText) != nil
                            let now = Date()
                            let dateValid = Calendar.current.startOfDay(for: date) <= Calendar.current.startOfDay(for: now)
                            let timeValid = Calendar.current.isDate(date, inSameDayAs: now) ? date <= now : true
                            let catValid = selectedCat.id != 0
                            
                            guard amtValid, dateValid, timeValid, catValid else {
                                validationMessage = "Пожалуйста, заполните все поля корректно"
                                showValidationAlert = true
                                return
                            }
                            
                            Task { await saveAndDismiss() }
                        }
                        .disabled(account == nil || selectedCat.id == 0)
                    }
                }
                .alert("Ошибка валидации", isPresented: $showValidationAlert) {
                    Button("Понял") { showValidationAlert = false }
                } message: {
                    Text(validationMessage)
                }
                .alert("Ошибка", isPresented: Binding(
                    get: { networkUIUtil.errorMessage != nil },
                    set: { if !$0 { networkUIUtil.errorMessage = nil } }
                )) {
                    Button("OK") { }
                } message: {
                    Text(networkUIUtil.errorMessage ?? "Произошла неизвестная ошибка")
                }
                .task { await loadInitialData() }
                .onAppear {
                    print("TransactionFormView appeared with mode: \(mode), direction: \(direction)")
                }
                .onChange(of: selectedCat) { newValue in
                    previousCategoryId = newValue.id != 0 ? newValue.id : nil // Update previous ID only for valid categories
                }
                
                if networkUIUtil.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                }
            }
            .tint(.purple)
        }
    }
    
    private func loadInitialData() async {
        do {
            print("Starting loadInitialData for mode: \(mode)")
            try await networkUIUtil.perform {
                print("Fetching account...")
                account = try await accountsService.getAccount()
                print("Account fetched: \(String(describing: account))")
                
                print("Fetching categories...")
                let allCategories = try await categoriesService.getAllCategories()
                print("Raw categories count: \(allCategories.count)")
                let wantIncome = (mode == .create) ? (direction == .income) : mode.transaction?.category.isIncome ?? false
                categories = allCategories.filter { $0.isIncome == wantIncome }
                print("Filtered categories count: \(categories.count)")
                
                if case .edit(let tx) = mode {
                    amountText = tx.amount.description
                    comment = tx.comment ?? ""
                    date = tx.transactionDate
                    selectedCat = tx.category
                    print("Edit mode initialized with transaction ID: \(tx.id)")
                } else if !categories.isEmpty {
                    // Set selectedCat to previous selection if valid, otherwise use first category only if no previous selection
                    if let prevId = previousCategoryId, let prevCat = categories.first(where: { $0.id == prevId }) {
                        selectedCat = prevCat
                    } else if previousCategoryId == nil {
                        selectedCat = categories[0] // Use first category only if no previous selection
                    }
                    amountText = ""
                    comment = ""
                    date = Date()
                    print("Create mode initialized with category: \(selectedCat.name)")
                } else {
                    selectedCat = Category(id: 0, name: "…", isIncome: false, emoji: " ")
                    print("No categories available, using placeholder")
                }
            }
        } catch {
            print("LoadInitialData error: \(error)")
        }
    }
    
    private func saveAndDismiss() async {
        guard let acct = account, let amt = Decimal(string: amountText) else {
            print("Save failed: Invalid account or amount")
            return
        }
        
        let tx = Transaction(
            id: mode.transaction?.id ?? 0,
            account: acct,
            category: selectedCat,
            amount: amt,
            transactionDate: date,
            comment: comment.isEmpty ? nil : comment,
            createdAt: mode.transaction?.createdAt ?? Date(),
            updatedAt: Date()
        )
        
        do {
            try await networkUIUtil.perform {
                print("Saving transaction with ID: \(tx.id)")
                if case .edit = mode {
                    try await txService.updateTransaction(tx)
                    print("Transaction updated")
                } else {
                    try await txService.createTransaction(tx)
                    print("Transaction created")
                }
            }
            dismiss()
        } catch {
            print("Save error: \(error)")
        }
    }
}

private extension TXFormMode {
    var transaction: Transaction? {
        if case .edit(let t) = self { return t }
        return nil
    }
}



import SwiftUI
import SwiftData

struct TransactionFormView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            do {
                let config = ModelConfiguration(isStoredInMemoryOnly: true)
                let container = try ModelContainer(
                    for: TransactionModel.self, BackupOperationModel.self,
                    configurations: config
                )
                let txService = TransactionsService(token: "KG8ToQeYtryu7MJ24PIhmdtc", container: container)
                return AnyView(
                    NavigationStack {
                        TransactionFormView(mode: .create, direction: .outcome)
                            .environmentObject(txService)
                            .environmentObject(BankAccountsService())
                            .environmentObject(CategoriesService())
                            .environmentObject(NetworkUIUtil())
                            .modelContainer(container)
                    }
                )
            } catch {
                return AnyView(
                    Text("Failed to create preview: \(error.localizedDescription)")
                )
            }
        }
    }
}
