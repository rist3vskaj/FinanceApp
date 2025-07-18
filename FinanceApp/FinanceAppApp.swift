import SwiftUI

@main
struct FinanceAppApp: App {
    // 1) Keep your TransactionsService
    @StateObject private var txStore = TransactionsService(token: "KG8ToQeYtryu7MJ24PIhmdtc")
    // 2) Add your one‐and‐only account service
    @StateObject private var accountsStore = BankAccountsService()

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor    = UIColor.gray.withAlphaComponent(0.3)

        UITabBar.appearance().standardAppearance   = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
              // 3) Inject *both* services
              .environmentObject(txStore)
              .environmentObject(accountsStore)
        }
    }
}

#Preview {
    MainTabView()
      .environmentObject(TransactionsService(token: "KG8ToQeYtryu7MJ24PIhmdtc"))
      .environmentObject(BankAccountsService())
}
