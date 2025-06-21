import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: TransactionsService

    var body: some View {
        TabView {
            // Расходы
            NavigationStack {
                TransactionListView(
                    direction: .outcome
                )
            }
            .tabItem {
                Image("razhod")
                  .renderingMode(.template)
                Text("Расходы")
            }

            // Доходы
            NavigationStack {
                TransactionListView(
                        direction: .income
                )
            }
            .tabItem {
                Image("dohod")
                  .renderingMode(.template)
                Text("Доходы")
            }

            // Счёт (stub)
            NavigationStack {
                Text("Счёт")
            }
            .tabItem {
                Image("schet")
                  .renderingMode(.template)
                Text("Счёт")
            }

            // Статьи (stub)
            NavigationStack {
                Text("Статьи")
            }
            .tabItem {
                Image("statistics")
                  .renderingMode(.template)
                Text("Статьи")
            }

            // Настройки (stub)
            NavigationStack {
                Text("Настройки")
            }
            .tabItem {
                Image("settings")
                  .renderingMode(.template)
                Text("Настройки")
            }
        }
        .accentColor(Color("MainColor"))
    }
}
