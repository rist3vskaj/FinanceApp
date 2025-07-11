import Foundation

@MainActor
final class TransactionViewModel: ObservableObject {
    @Published var filteredTransactions: [Transaction] = []
    @Published var totalAmount: Decimal = 0
    @Published var isLoading = false
    @Published var errorMessage: String?

   var service: TransactionsService
    let direction: Direction

    init(direction: Direction, service: TransactionsService) {
        self.direction = direction
        self.service   = service
    }

    func loadTransactions() {
        Task {
            isLoading = true
            errorMessage = nil

            let now = Date()
            let cal = Calendar.current
            let startOfDay = cal.startOfDay(for: now)
            let endOfDay   = cal.date(
              bySettingHour: 23, minute: 59, second: 59, of: now
            )!

            do {
                let all = try await service.getTransactions(
                  from: startOfDay,
                  to: endOfDay
                )
                let matching = all.filter {
                  $0.category.direction == self.direction
                }
                filteredTransactions = matching
                totalAmount         = matching.reduce(0) { $0 + $1.amount }
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }
}
