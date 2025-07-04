import SwiftUI

@main
struct FinanceAppApp: App {
  
    @StateObject private var store = TransactionsService()


    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        appearance.shadowColor    = UIColor.gray.withAlphaComponent(0.3)
      

        UITabBar.appearance().standardAppearance    = appearance
        UITabBar.appearance().scrollEdgeAppearance  = appearance
    }

    var body: some Scene {
        WindowGroup {
          
            MainTabView()
                .environmentObject(store)
        }
    }
}

#Preview {

    MainTabView()
      .environmentObject(TransactionsService())
}
