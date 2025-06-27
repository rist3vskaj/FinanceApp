import SwiftUI

@main
struct FinanceAppApp: App {
    // 1️⃣ Create your shared service
    //    (make sure TransactionsService is ObservableObject,
    //     or wrap it in one if it isn’t)
    @StateObject private var store = TransactionsService()

    // 2️⃣ (Optional) Customize the real UITabBar’s appearance:
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        appearance.shadowColor    = UIColor.gray.withAlphaComponent(0.3)
        // If you want rounded corners at the top of the bar,
        // you’d need a custom backgroundImage mask here.

        UITabBar.appearance().standardAppearance    = appearance
        UITabBar.appearance().scrollEdgeAppearance  = appearance
    }

    var body: some Scene {
        WindowGroup {
            // 3️⃣ Inject it into your view hierarchy
            MainTabView()
                .environmentObject(store)
        }
    }
}

#Preview {
    // Don’t forget the .environmentObject in previews too:
    MainTabView()
      .environmentObject(TransactionsService())
}
