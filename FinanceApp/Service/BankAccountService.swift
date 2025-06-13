import Foundation

final class BankAccountsService {
    private var mockAccount = BankAccount(
        id: 1,
        userId: 1,
        name: "Основной счёт",
        balance: 1000.00,
        currency: "RUB",
        createdAt: Date(),
        updatedAt: Date()
    )

    func getAccount() async throws -> BankAccount {
        return mockAccount
    }

    func updateAccount(_ account: BankAccount) async throws {
        mockAccount = account
    }
}
