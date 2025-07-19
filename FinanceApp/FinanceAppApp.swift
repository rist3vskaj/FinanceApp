import SwiftUI

@main
struct FinanceAppApp: App {
    @StateObject private var txStore = TransactionsService(token: "KG8ToQeYtryu7MJ24PIhmdtc")
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
              .environmentObject(txStore)
              .environmentObject(accountsStore)
        }
    }
}

#Preview {
    MainTabView()
      .environmentObject(TransactionsService(token: "KG8ToQeYtryu7MJ24PIhmdtc"))
      .environmentObject(BankAccountsService())
      .environmentObject(CategoriesService())
      .environmentObject(NetworkUIUtil())
}
