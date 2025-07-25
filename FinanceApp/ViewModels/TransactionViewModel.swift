import Foundation
import SwiftUICore

@MainActor
final class TransactionViewModel: ObservableObject {
    @Published var filteredTransactions: [Transaction] = []
    @Published var totalAmount: Decimal = 0
    private let service: TransactionsService // Replace @EnvironmentObject with a stored property
    let direction: Direction

    init(direction: Direction, service: TransactionsService) {
        self.direction = direction
        self.service = service
        print("TransactionViewModel initialized with direction: \(direction)")
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
            print("Failed to load transactions: \(error)")
            filteredTransactions = []
            totalAmount = 0
        }
    }
}
