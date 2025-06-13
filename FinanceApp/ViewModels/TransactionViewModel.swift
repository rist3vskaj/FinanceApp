import Foundation

@MainActor
final class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = TransactionsService()

    func loadTransactions() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await service.getAllTransactions()
            transactions = fetched
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
