import Foundation

/// A singleton service that holds exactly one account.
final class BankAccountsService: ObservableObject {
    @Published private var mockAccount = BankAccount(
        id: 1,
        userId: 1,
        name: "Основной счёт",
        balance: Decimal(string: "1000.00")!,
        currency: "RUB",
        createdAt: Date(),
        updatedAt: Date()
    )
  
    /// SwiftUI views can read this via @EnvironmentObject
    var account: BankAccount { mockAccount }

    func getAccount() async throws -> BankAccount {
        mockAccount
    }

    func updateAccount(_ account: BankAccount) async throws {
        mockAccount = account
    }
}
