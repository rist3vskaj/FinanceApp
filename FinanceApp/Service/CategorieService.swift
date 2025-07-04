final class CategoriesService {
    private let transactionsService: TransactionsService

    init(transactionsService: TransactionsService = TransactionsService()) {
        self.transactionsService = transactionsService
    }
    
  

    func getAllCategories() async throws -> [Category] {
        let transactions = try await transactionsService.getAllTransactions()

        // Extract categories and remove duplicates (by ID)
        let unique = Dictionary(
            grouping: transactions.map(\.category),
            by: \.id
        ).compactMap { $0.value.first }

        return unique
    }

    func getCategories(for direction: Direction) async throws -> [Category] {
        let all = try await getAllCategories()
        return all.filter { $0.direction == direction }
    }
}
