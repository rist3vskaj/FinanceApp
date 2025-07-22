import SwiftUI

@main
struct FinanceAppApp: App {
    @StateObject private var txStore = TransactionsService(token: "KG8ToQeYtryu7MJ24PIhmdtc")
    @StateObject private var accountsStore = BankAccountsService()
    @StateObject private var networkUIUtil = NetworkUIUtil()
    @StateObject private var categoriesService = CategoriesService()

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
              .environmentObject(networkUIUtil)
              .environmentObject(categoriesService)
            
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
