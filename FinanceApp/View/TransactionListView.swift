import SwiftUI
struct TransactionListView: View {
    let direction: Direction
    let service: TransactionsService  // Add this property

    @EnvironmentObject private var accountsService: BankAccountsService
    @EnvironmentObject private var networkUIUtil: NetworkUIUtil
    @EnvironmentObject private var categoriesService: CategoriesService

    @StateObject private var vm: TransactionViewModel
    @State private var editingTx: Transaction?
    @State private var showingCreate = false

    init(direction: Direction, service: TransactionsService) {
        self.direction = direction
        self.service = service
        _vm = StateObject(
            wrappedValue: TransactionViewModel(direction: direction, service: service)
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 16) {
                        header
                        totalCard
                        transactionList
                    }
                    .padding(.top)
                }
                .navigationBarHidden(true)
                .fullScreenCover(item: $editingTx, onDismiss: reload) { tx in
                    TransactionFormView(mode: .edit(tx), direction: direction)
                        .environmentObject(service)  // Use the stored service
                        .environmentObject(accountsService)
                        .environmentObject(networkUIUtil)
                        .environmentObject(categoriesService)
                }
                .fullScreenCover(isPresented: $showingCreate, onDismiss: reload) {
                    TransactionFormView(mode: .create, direction: direction)
                        .environmentObject(service)  // Use the stored service
                        .environmentObject(accountsService)
                        .environmentObject(networkUIUtil)
                        .environmentObject(categoriesService)
                }
                .task {
                    await vm.loadTransactions()
                }
                .overlay(alignment: .bottomTrailing) {
                    addButton
                        .padding(24)
                }
            }
            .onAppear {
                Task { await vm.loadTransactions() }
            }
        }
    }

    // MARK: – Subviews (unchanged except for historyView)

    private var header: some View {
        HStack {
            Text(direction == .income ? "Доходы сегодня" : "Расходы сегодня")
                .font(.largeTitle).bold()
            Spacer()
            NavigationLink(destination: historyView) {
                Image(systemName: "clock")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.purple)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .background(Color(.systemGray6))
        .frame(maxWidth: .infinity)
        .zIndex(1)
    }

    private var historyView: some View {
        HistoryView(direction: direction, txService: service, bankAccService: accountsService)
            .environmentObject(service)  // Update to use service
            .environmentObject(accountsService)
            .environmentObject(networkUIUtil)
            .environmentObject(categoriesService)
    }

    private var totalCard: some View {
        HStack {
            Text("Всего").font(.headline)
            Spacer()
            Text(vm.totalAmount.formatted(.currency(code: "RUB")))
                .font(.headline)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var transactionList: some View {
        VStack(spacing: 0) {
            ForEach(vm.filteredTransactions) { tx in
                Button { editingTx = tx } label: {
                    transactionRow(tx)
                }
                .buttonStyle(.plain)

                if tx.id != vm.filteredTransactions.last?.id {
                    Divider()
                        .padding(.leading, 56)
                        .padding(.trailing, 16)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private func transactionRow(_ tx: Transaction) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color("MainColor").opacity(0.3))
                    .frame(width: 30, height: 30)
                Text(String(tx.category.emoji))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(tx.category.name)
                if let c = tx.comment {
                    Text(c)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Text(tx.amount.formatted(.currency(code: "RUB")))
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
    }

    private var addButton: some View {
        Button { showingCreate = true } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 66, height: 66)
                .background(Color("MainColor"))
                .clipShape(Circle())
        }
    }

    // MARK: – Helpers

    private func reload() {
        Task {
            await vm.loadTransactions()
        }
    }
}


import SwiftData

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: TransactionModel.self, BackupOperationModel.self,
            configurations: config
        )
        let txService = TransactionsService(token: "KG8ToQeYtryu7MJ24PIhmdtc", container: container)
        return MainTabView()
            .environmentObject(txService)
            .environmentObject(BankAccountsService())
            .environmentObject(CategoriesService())
            .environmentObject(NetworkUIUtil())
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
