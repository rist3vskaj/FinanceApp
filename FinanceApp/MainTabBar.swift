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
                MyBankAccountView()
            }
            .tabItem {
                Image("schet")
                  .renderingMode(.template)
                Text("Счёт")
            }

            
            NavigationStack {
                ArticlesView()
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
                Image("settings 1")
                  .renderingMode(.template)
                Text("Настройки")
            }
        }
        .accentColor(Color("MainColor"))
    }
}
