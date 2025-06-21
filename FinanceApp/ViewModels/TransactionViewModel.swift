import Foundation

@MainActor
final class TransactionViewModel: ObservableObject {
    @Published var filteredTransactions: [Transaction] = []
    @Published var totalAmount: Decimal = 0
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = TransactionsService()

    func loadTransactions(for direction: Direction) {
        Task {
            isLoading = true
            errorMessage = nil

            let now = Date()
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now)!

            do {
                let all = try await service.getTransactions(from: startOfDay, to: endOfDay)
                
    
                let matching = all.filter { $0.category.direction == direction }

            
                self.filteredTransactions = matching
                self.totalAmount = matching.reduce(0) { $0 + $1.amount }
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }
}

