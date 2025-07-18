import SwiftUI

/// Create vs Edit
enum TXFormMode: Equatable {
  case create
  case edit(Transaction)
}

struct CategoryPickerView: View {
  @Binding var selection: Category
  let categories: [Category]

  var body: some View {
    List(categories) { c in
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
  @Environment(\.dismiss)   private var dismiss
    @EnvironmentObject private var categoriesService: CategoriesService

    
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
                        HStack {
                          Text("Статья")
                          Spacer()
                          NavigationLink {
                            CategoryPickerView(selection: $selectedCat,
                                               categories: categories)
                          } label: {
                            HStack(spacing: 4) {
                              Text(selectedCat.name.isEmpty ? "—" : selectedCat.name)
                                .foregroundColor(selectedCat.name.isEmpty ? .secondary : .primary)
                              Image(systemName: "chevron.right")
                            }
                          }
                        }
                    } else {
                        // —— CREATE MODE: free-form text field instead
                        // и для create, и для edit — показываем NavigationLink:
                        Section {
                          NavigationLink {
                            CategoryPickerView(selection: $selectedCat,
                                               categories: categories)
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
                        }
//                        label: {
//                          HStack {
//                            Text("Статья")
//                            Spacer()
//                            Text(selectedCat.name.isEmpty ? "—" : selectedCat.name)
//                              .foregroundColor(selectedCat.name.isEmpty ? .secondary : .primary)
//                            Image(systemName: "chevron.right")
//                              .foregroundColor(.gray)
//                          }
//                        }

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
                                       
                                          
                                          guard amtValid, dateValid, timeValid else {
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
                                      // 1) fetch account, как было
                                      amountText = ""
                                      comment = ""
                                      date = Date()

                                      // 2) загрузить категории для выбранного направления (доход/расход)
//                                      let allTx = (try? await txService.getAllTransactions()) ?? []
                                  //    let wantIncome = (direction == .income)
                                        
                                        let allTx = (try? await txService.getAllTransactions()) ?? []

                                           // 2) определяем, какие категории нам нужны (доходные или расходные)
                                           let wantIncome: Bool = {
                                               switch mode {
                                               case .create:
                                                   return direction == .income
                                               case .edit(let tx):
                                                   return tx.category.isIncome
                                               }
                                           }()

                                           // 3) получаем уникальный список категорий нужного направления
                                           let rawCategories = allTx
                                             .map(\.category)
                                             .filter { $0.isIncome == wantIncome }
                                             .removingDuplicates()

                                           // 4) для каждой категории считаем сумму её операций
                                           categories = rawCategories.map { cat in
                                             let sumForCat = allTx
                                               .filter { $0.category.id == cat.id }
                                               .map(\.amount)
                                               .reduce(0, +)
                                             return Category(
                                               id: cat.id,
                                               name: cat.name,
                                               isIncome: cat.isIncome,
                                               emoji: cat.emoji
                                                // ← сюда передаём вычисленную сумму
                                             )
                                           }

                                           // 5) в режиме create можно сразу выбрать первую категорию по умолчанию
                                        if case .create = mode, selectedCat == nil, let first = categories.first {
                                               selectedCat = first
                                           }
                                        // передайте direction в этот экран
                                      categories = allTx
                                        .map(\.category)
                                        .filter { $0.isIncome == wantIncome }
                                        .removingDuplicates()



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
                                       else { return }

                                       // попробуем получить все, если упадёт — возьмём пустой массив
                                       let all = (try? await txService.getAllTransactions()) ?? []
                                       let newId = (all.map(\.id).max() ?? 0) + 1

                                       let tx = Transaction(
                                         id: newId,
                                         account: acct,
                                         category: selectedCat,
                                         amount: amt,
                                         transactionDate: date,
                                         comment: comment.isEmpty ? nil : comment,
                                         createdAt: mode.transaction?.createdAt ?? Date(),
                                         updatedAt: Date()
                                       )

                                       do {
                                         try await txService.createTransaction(tx)
                                         if let idx = categories.firstIndex(where: { $0.id == selectedCat.id }) {
                                             try await categories                                         }
                                         dismiss()
                                       } catch {
                                         print("Ошибка при создании или обновлении:", error)
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
    .environmentObject(TransactionsService(token: "KG8ToQeYtryu7MJ24PIhmdtc"))
    .environmentObject(BankAccountsService())
      
  }
}
