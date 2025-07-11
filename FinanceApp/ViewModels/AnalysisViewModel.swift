import Foundation

@MainActor
final class AnalysisViewModel: ObservableObject {
    let service: TransactionsService
    let accountId: Int
    let direction: Direction

    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var totalAmount: Decimal    = 0

    @Published var startDate: Date
    @Published var endDate:   Date

    init(
        direction:  Direction,
        accountId:  Int,
        service:    TransactionsService
    ) {
        self.direction = direction
        self.accountId = accountId
        self.service   = service

        let now = Date()
        self.endDate   = now
        self.startDate = Calendar.current.date(
            byAdding: .month,
            value: -1,
            to: now
        )!

        Task { await loadTransactions() }
    }

    func loadTransactions() async {
        // keep dates valid
        if startDate > endDate {
            endDate = startDate
        }

        do {
            // call your actual API
            let allInRange = try await service.getTransactions(
                from: startDate,
                to:   endDate
            )

            // then filter by accountId & direction
            let filtered = allInRange.filter {
                $0.account.id == accountId
                && $0.category.direction == direction
            }

            // publish
            transactions = filtered
            totalAmount  = filtered
                .map { $0.amount }
                .reduce(0, +)

        } catch {
            print("⚠️ AnalysisViewModel.loadTransactions failed:", error)
        }
    }
}
