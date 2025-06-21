import Foundation

@MainActor
final class BankAccountViewModel: ObservableObject {
    @Published var account: BankAccount?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = BankAccountsService()

    func loadAccount() async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await service.getAccount()
            account = result
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
