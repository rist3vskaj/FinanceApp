import SwiftUI
import SwiftData

@main
struct FinanceAppApp: App {
    private let modelContainer: ModelContainer
    
    @StateObject private var txStore: TransactionsService
    @StateObject private var accountsStore = BankAccountsService()
    @StateObject private var networkUIUtil = NetworkUIUtil()
    @StateObject private var categoriesService = CategoriesService()

    init() {
        do {
            let container = try ModelContainer(for: TransactionModel.self, BackupOperationModel.self)
            self.modelContainer = container
            self._txStore = StateObject(wrappedValue: TransactionsService(token: "KG8ToQeYtryu7MJ24PIhmdtc", container: container))
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = UIColor.gray.withAlphaComponent(0.3)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(txStore)
                .environmentObject(accountsStore)
                .environmentObject(networkUIUtil)
                .environmentObject(categoriesService)
                .modelContainer(modelContainer)
        }
        .modelContainer(modelContainer)
    }
}

#Preview {
    let container = try! ModelContainer(for: TransactionModel.self, BackupOperationModel.self)
    MainTabView()
        .environmentObject(TransactionsService(token: "KG8ToQeYtryu7MJ24PIhmdtc", container: container))
        .environmentObject(BankAccountsService())
        .environmentObject(CategoriesService())
        .environmentObject(NetworkUIUtil())
        .modelContainer(container)
}
