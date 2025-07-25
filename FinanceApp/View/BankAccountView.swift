import SwiftUI

struct MyBankAccountView: View {
    @StateObject private var vm = BankAccountViewModel()
    @State private var isEditing       = false
    @State private var showCurrency    = false
    @State private var balanceText     = ""
    @State private var isBalanceHidden = false
    @State private var showTintDialog = false
       @State private var showAccentDialog = false
    @State var spoilerIsOn = true
       
      
       init(){
           UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(.purple)
       }
       

    // Filters the pasteboard string: only digits + one dot
    private var filteredPaste: String {
        let raw = UIPasteboard.general.string ?? ""
        var seenDot = false
        return raw.reduce(into: "") { acc, c in
            if c.isWholeNumber {
                acc.append(c)
            } else if c == ".", !seenDot {
                seenDot = true
                acc.append(c)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Title
                    Text("Мой счёт")
                        .font(.system(size: 36, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, -50)

                    // Balance row wrapped in spoiler
                    Spoiler(isHidden: $isBalanceHidden) {
                        HStack {
                            Text("💰")
                            Text("Баланс")
                                .font(.headline)
                            Spacer()

                            if isEditing {
                                TextField("0", text: $balanceText)
                                  .keyboardType(.decimalPad)
                                  .multilineTextAlignment(.trailing)
                                  .font(.headline)
                                  .frame(width: 120)
                               
                                  .onChange(of: balanceText) { newValue in
                                    var filtered = ""
                                    var dotSeen = false
                                    for ch in newValue {
                                      if ch.isWholeNumber {
                                        filtered.append(ch)
                                      } else if ch == "." && !dotSeen {
                                        dotSeen = true
                                        filtered.append(ch)
                                      }
                                    }
                                    if filtered != newValue {
                                      balanceText = filtered
                                    }
                                  }
                                  
                                  .contextMenu {
                                    Button("Paste") {
                                      balanceText = UIPasteboard.general.string ?? ""
                                    }
                                  }
                            } else {
                                Text(
                                  vm.account?
                                    .balance
                                    .formatted(.currency(code: vm.account?.currency ?? "RUB"))
                                  ?? "0 ₽"
                                )
                                .font(.headline)
                                .spoiler(isOn: $isBalanceHidden)
                            }
                        }
                        .padding()
                        .background(Color("MainColor"))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    // listen for shakes
                    .background(ShakeDetector {
                        withAnimation {
                            isBalanceHidden.toggle()
                        }
                    })

                    // Currency row
                    HStack {
                        Text("Валюта")
                            .font(.headline)
                        Spacer()
                        Text(vm.account?.currency ?? "RUB")
                            .font(.headline)
                            .foregroundColor(isEditing ? .purple : .primary)
                    }
                    .padding()
                    .background(Color("MainColor").opacity(0.3))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .onTapGesture {
                        if isEditing {
                            showCurrency = true
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 40)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .refreshable {
                await vm.loadAccount()   // or your real async load
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Edit / Save button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Сохранить" : "Редактировать") {
                        if isEditing,
                           let newBal = Decimal(string: balanceText)
                        {
                            vm.account?.balance = newBal
                        } else {
                            balanceText = vm.account?.balance.description ?? ""
                        }
                        withAnimation { isEditing.toggle() }
                    }
                    .tint(.purple)
                }
            }
            .confirmationDialog("Выберите валюту",
                                isPresented: $showCurrency,
                                titleVisibility: .visible)
            {
                ForEach(Currency.allCases) { cur in
                    Button(cur.displayName) {
                        vm.account?.currency = cur.rawValue
                    }
                }
                Button("Отмена", role: .cancel) { }
            }
            .task {
                await vm.loadAccount()
            }
        }
    }
}
import SwiftUI
import SwiftData

struct MyBankAccountView_Previews: PreviewProvider {
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
                        MyBankAccountView()
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
