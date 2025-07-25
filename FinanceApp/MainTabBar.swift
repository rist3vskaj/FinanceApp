import SwiftUI
import SwiftData

struct MainTabView: View {
    @EnvironmentObject var store: TransactionsService
        @EnvironmentObject var account: BankAccountsService
        @EnvironmentObject var category: CategoriesService
        @EnvironmentObject var networkUIUtil: NetworkUIUtil

    var body: some View {
        TabView {
            // Расходы
            NavigationStack {
                TransactionListView(direction: .outcome, service: store)
            }
            .tabItem {
                Image("razhod")
                    .renderingMode(.template)
                Text("Расходы")
            }

            // Доходы
            NavigationStack {
                TransactionListView(direction: .income, service: store)
            }
            .tabItem {
                Image("dohod")
                    .renderingMode(.template)
                Text("Доходы")
            }

            // Счёт
            NavigationStack {
                MyBankAccountView()
            }
            .tabItem {
                Image("schet")
                    .renderingMode(.template)
                Text("Счёт")
            }

            // Статьи
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

#Preview {
    do {
        let container = try ModelContainer(for: TransactionModel.self, BackupOperationModel.self)
        let txService = TransactionsService(token: "KG8ToQeYtryu7MJ24PIhmdtc", container: container)
        return MainTabView()
            .environmentObject(txService)
            .environmentObject(BankAccountsService())
            .environmentObject(CategoriesService())
            .environmentObject(NetworkUIUtil())
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
