import SwiftUI

/// Create vs Edit
enum TXFormMode: Equatable {
  case create
  case edit(Transaction)
}

struct TransactionFormView: View {
  @EnvironmentObject private var txService: TransactionsService
  @EnvironmentObject private var accountsService: BankAccountsService
  @Environment(\.dismiss)   private var dismiss
    
    @State private var newCategoryName: String = ""
    @State private var showValidationAlert = false
    @State private var validationMessage = ""

  let mode: TXFormMode
    let direction: Direction

  @State private var account     : BankAccount?
  @State private var categories  : [Category] = []
  @State private var selectedCat : Category    = .init(id:0,name:"…",isIncome:false,emoji:" ")
  @State private var amountText  : String      = ""
  @State private var date        : Date        = Date()
  @State private var comment     : String      = ""
    
    private var decimalSeparator: String {
      Locale.current.decimalSeparator ?? "."
    }
    var body: some View {
        NavigationStack {
            Form {
                // — Delete only in edit
//                if case .edit(let tx) = mode {
//                    Section {
//                        Button("Удалить операцию", role: .destructive) {
//                            Task {
//                                try? await txService.deleteTransaction(id: tx.id)
//                                dismiss()
//                            }
//                        }
//                    }
//                }
                
                // — Article picker
                Section(" ") {
                    if case .edit = mode {
                        // —— EDIT MODE: tap to pick from your list
                        NavigationLink {
                            List(categories, id: \.id) { c in
                                HStack {
                                    Text(c.name)
                                    Spacer()
                                    if c.id == selectedCat.id {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedCat = c
                                    dismiss()
                                }
                            }
                            .navigationTitle("Статья")
                        } label: {
                            HStack {
                                Text("Статья")
                                Spacer()
                                Text(selectedCat.name)
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                    } else {
                        // —— CREATE MODE: free-form text field instead
                        HStack {
                            Text("Статья")
                            Spacer()
                            TextField("Введите статью", text: $newCategoryName)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.primary)
                                .placeholder(when: newCategoryName.isEmpty) {
                                    Text(" ")
                                        .foregroundColor(.secondary)
                                }
                        }
                    }
                    
                    
                    // — Amount
                   
                    HStack {
                        Text("Сумма")
                        TextField("0\(decimalSeparator)00", text: $amountText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: amountText) { new in
                                // Allow only digits plus at most one decimal separator:
                                let allowed = CharacterSet.decimalDigits
                                    .union(CharacterSet(charactersIn: decimalSeparator))
                                var filtered = new
                                    .filter { char in
                                        String(char).rangeOfCharacter(from: allowed) != nil
                                    }
                                
                                let parts = filtered.components(separatedBy: decimalSeparator)
                                if parts.count > 2 {
                                    // join first two again, then append the rest without separators
                                    filtered = parts[0]
                                    + decimalSeparator
                                    + parts[1]
                                    + parts.dropFirst(2).joined()
                                }
                                if filtered != new {
                                    amountText = filtered
                                }
                            }
                    }
                    
                    
                    // — Date & Time
                    
                    HStack {
                        Text("Дата")
                        Spacer ()
                                            DatePicker(
                                                "",
                                                selection: $date,
                                                in: ...Date(),    // never allow a date in the future
                                                displayedComponents: .date
                                            )
                                            .labelsHidden()
                                            .datePickerStyle(.compact)
                                        }
                                        HStack {
                                            Text("Время")
                                            Spacer ()
                                            DatePicker("Время", selection: $date, displayedComponents: .hourAndMinute)
                                                .labelsHidden()
                                                .datePickerStyle(.compact)
                                        }
                                        
                                        
                                        // — Comment
                                       
                                            ZStack(alignment: .topLeading) {
                                                TextEditor(text: $comment).frame(minHeight:80)
                                                if comment.isEmpty {
                                                    Text("Комментарий")
                                                        .foregroundColor(.gray)
                                                        .padding(.horizontal,4)
                                                        .padding(.vertical,8)
                                                
                                            }
                                        }
                    
                                    }
                if case .edit(let tx) = mode {
                    Section {
                        Button("Удалить операцию", role: .destructive) {
                            Task {
                                try? await txService.deleteTransaction(id: tx.id)
                                dismiss()
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
                              //.navigationBarTitleDisplayMode(.inline)
                              .toolbar {
                                  ToolbarItem(placement:.navigationBarLeading) {
                                      Button("Отмена") { dismiss() }
                                  }
                                  ToolbarItem(placement: .navigationBarTrailing) {
                                      Button(mode == .create ? "Создать" : "Сохранить") {
                                          let amtValid = !amountText.isEmpty && Decimal(string: amountText) != nil
                                          let commentValid = !comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                          let now = Date()
                                          let dateValid = Calendar.current.startOfDay(for: date)
                                          <= Calendar.current.startOfDay(for: now)
                                          
                                          // 5) if user chose today, time must not be ahead of now
                                          let timeValid: Bool = {
                                              if Calendar.current.isDate(date, inSameDayAs: now) {
                                                  return date <= now
                                              } else {
                                                  return true
                                              }
                                          }()
                                          // catValid means:
                                          //   - create ⇒ newCategoryName must not be blank
                                          //   - edit   ⇒ selectedCat must have a real id
                                          let catValid: Bool = {
                                              switch mode {
                                              case .create:
                                                  return !newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty
                                              case .edit:
                                                  return selectedCat.id != 0
                                              }
                                          }()
                                          
                                          guard amtValid, catValid, commentValid, dateValid, timeValid else {
                                              validationMessage = """
                                          Пожалуйста, заполните все поля
                                          
                                          """
                                              showValidationAlert = true
                                              return
                                          }
                                          
                                          Task { await saveAndDismiss() }
                                      }
                                      .disabled(account == nil)
                                  }
                              }
                                    // This is the *only* navigationDestination you need:
                                    .navigationDestination(for: Category.self) { _ in
                                      List(categories, id:\.id) { c in
                                        HStack {
                                          Text(c.name)
                                          Spacer()
                                          if c.id == selectedCat.id {
                                            Image(systemName:"checkmark")
                                          }
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                          selectedCat = c
                                          dismiss()
                                        }
                                      }
                                      .navigationTitle("Статья")
                                    }
                                    .task { await loadInitialData() }
                                    .alert(validationMessage, isPresented: $showValidationAlert) {
                                        Button("Понял") { showValidationAlert = false }
                                      }
                                    .alert(isPresented: $showValidationAlert) {
                                      Alert(
                                        title: Text("Ошибка валидации"),
                                        message: Text(validationMessage),
                                        dismissButton: .default(Text("Понял"))
                                      )
                                    }
        }.tint(.purple)
                                }

                                  private func loadInitialData() async {
                                    // 1) load the single bank account
                                    account = try? await accountsService.getAccount()

                                    switch mode {
                                    case .create:
                                      // a) clear out everything
                                      amountText  = ""
                                      comment     = ""
                                      date        = Date()
                                      categories  = []                   // ← no categories yet
                                      selectedCat = Category(            // ← blank placeholder
                                        id: 0,
                                        name: "",
                                        isIncome: false,
                                        emoji: " "
                                      )

                                    case .edit(let tx):
                                      // seed from the transaction
                                      amountText  = tx.amount.description
                                      comment     = tx.comment ?? ""
                                      date        = tx.transactionDate
                                      selectedCat = tx.category

                                      // now build categories only in edit
                                      let allTx = (try? await txService.getAllTransactions()) ?? []
                                      let wantIncome = tx.category.isIncome
                                      categories = allTx
                                        .map(\.category)
                                        .filter { $0.isIncome == wantIncome }
                                        .removingDuplicates()
                                    }
                                  }


                                  private func saveAndDismiss() async {
                                      guard
                                        let acct = account,
                                        let amt  = Decimal(string: amountText),
                                        !amountText.isEmpty
                                      else {
                                        return
                                      }

                                      // 1) choose or generate a transaction ID
                                      let newId: Int
                                      if case .edit(let tx) = mode {
                                        newId = tx.id
                                      } else {
                                        let all = (try? await txService.getAllTransactions()) ?? []
                                        newId = (all.map(\.id).max() ?? 0) + 1
                                      }

                                      // 2) pick the category: typed‐in in create, or existing in edit
                                      let categoryToUse: Category
                                      switch mode {
                                      case .create:
                                        // give your new category its own ID (or reuse newId)
                                        categoryToUse = Category(
                                          id: newId,
                                          name: newCategoryName,
                                          isIncome: false,   // or flip based on UI
                                          emoji: " "          // or however you want to populate it
                                        )
                                      case .edit:
                                        categoryToUse = selectedCat
                                      }

                                      // 3) build the Transaction
                                      let tx = Transaction(
                                        id: newId,
                                        account: acct,
                                        category: categoryToUse,
                                        amount: amt,
                                        transactionDate: date,
                                        comment: comment.isEmpty ? nil : comment,
                                        createdAt: mode.transaction?.createdAt ?? Date(),
                                        updatedAt: Date()
                                      )

                                      // 4) save via your service
                                      do {
                                        switch mode {
                                        case .create:
                                          try await txService.createTransaction(tx)
                                        case .edit:
                                          try await txService.updateTransaction(tx)
                                        }
                                        dismiss()
                                      } catch {
                                        print("save failed:", error)
                                      }
                                  }

                              }

                              // Helpers
                              private extension TXFormMode {
                                var transaction: Transaction? {
                                  if case .edit(let t) = self { return t }
                                  return nil
                                }
                              }
                              private extension Array where Element: Hashable {
                                func removingDuplicates() -> [Element] {
                                  var seen = Set<Element>()
                                  return filter { seen.insert($0).inserted }
                                }
                              }



                              // MARK: — Preview
struct TransactionFormView_Previews: PreviewProvider {
  static var previews: some View {
    TransactionFormView(
      mode: .create,
      direction: .outcome     // ← choose .income or .outcome here
    )
    .environmentObject(TransactionsService())
    .environmentObject(BankAccountsService())
  }
}
