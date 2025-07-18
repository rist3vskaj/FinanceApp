import Foundation

final class BankAccountsService: ObservableObject {
    @Published private var account: BankAccount?
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    /// SwiftUI views can read this via @EnvironmentObject
    var envAccount: BankAccount? { account }
    
    func getAccount() async throws -> BankAccount {
        // INSERT YOUR JWT TOKEN HERE
        let token = "KG8ToQeYtryu7MJ24PIhmdtc"
        
        let accounts: [BankAccount] = try await networkClient.request(
            endpoint: "/accounts",
            method: "GET",
            token: token
        )
        
        guard let firstAccount = accounts.first else {
            throw NetworkError.notFound
        }
        
        await MainActor.run {
            self.account = firstAccount
        }
        
        return firstAccount
    }
    
    func updateAccount(_ account: BankAccount) async throws {
        // INSERT YOUR JWT TOKEN HERE
        let token = "KG8ToQeYtryu7MJ24PIhmdtc"
        
        let updateRequest = AccountUpdateRequest(
            name: account.name,
            balance: account.balance.description,
            currency: account.currency
        )
        
        let updatedAccount: BankAccount = try await networkClient.request(
            endpoint: "/accounts/\(account.id)",
            method: "PUT",
            body: updateRequest,
            token: token
        )
        
        await MainActor.run {
            self.account = updatedAccount
        }
    }
}

struct AccountUpdateRequest: Encodable {
    let name: String
    let balance: String
    let currency: String
}
