import Foundation

@MainActor
final class TransactionViewModel: ObservableObject {
    @Published var filteredTransactions: [Transaction] = []
    @Published var totalAmount: Decimal = 0
    var service: TransactionsService
    let direction: Direction

    init(direction: Direction, service: TransactionsService) {
        self.direction = direction
        self.service = service
    }

    func loadTransactions() async {
        do {
            let now = Date()
            let cal = Calendar.current
            let startOfDay = cal.startOfDay(for: now)
            let endOfDay = cal.date(
                bySettingHour: 23, minute: 59, second: 59, of: now
            )!

            let all = try await service.getTransactions(
                from: startOfDay,
                to: endOfDay
            )
            let matching = all.filter {
                $0.category.direction == self.direction
            }
            filteredTransactions = matching
            totalAmount = matching.reduce(0) { $0 + $1.amount }
        } catch {
            // Handle the error appropriately
            print("Failed to load transactions: \(error)")
            // Optionally update the UI or state to reflect the error
            filteredTransactions = []
            totalAmount = 0
        }
    }
}
