import Foundation

final class TransactionsService: ObservableObject {
    private let networkClient: NetworkClientProtocol
    private let bankAccountsService: BankAccountsService
    private let token: String
    
    init(networkClient: NetworkClientProtocol = NetworkClient(), token: String) {
        self.networkClient = networkClient
        self.bankAccountsService = BankAccountsService(networkClient: networkClient)
        self.token = token
    }
    
    func getAllTransactions() async throws -> [Transaction] {
        let responses: [TransactionResponse] = try await networkClient.request(
            endpoint: "/transactions",
            method: "GET",
            token: token
        )
        
        let accounts = try await fetchAccounts()
        let categories = try await fetchCategories()
        
        return try responses.map { response in
            guard let account = accounts.first(where: { $0.id == response.accountId }),
                  let category = categories.first(where: { $0.id == response.categoryId }) else {
                throw NetworkError.notFound
            }
            
            return Transaction(
                id: response.id,
                account: account,
                category: category,
                amount: response.amount,
                transactionDate: response.transactionDate,
                comment: response.comment,
                createdAt: response.createdAt,
                updatedAt: response.updatedAt
            )
        }
    }
    
    func getTransactions(from start: Date, to end: Date) async throws -> [Transaction] {
        let dateFormatter = ISO8601DateFormatter()
        let startDate = dateFormatter.string(from: start)
        let endDate = dateFormatter.string(from: end)
        
        let responses: [TransactionResponse] = try await networkClient.request(
            endpoint: "/transactions?start_date=\(startDate)&end_date=\(endDate)",
            method: "GET",
            token: token
        )
        
        let accounts = try await fetchAccounts()
        let categories = try await fetchCategories()
        
        return try responses.map { response in
            guard let account = accounts.first(where: { $0.id == response.accountId }),
                  let category = categories.first(where: { $0.id == response.categoryId }) else {
                throw NetworkError.notFound
            }
            
            return Transaction(
                id: response.id,
                account: account,
                category: category,
                amount: response.amount,
                transactionDate: response.transactionDate,
                comment: response.comment,
                createdAt: response.createdAt,
                updatedAt: response.updatedAt
            )
        }
    }
    
    func createTransaction(_ transaction: Transaction) async throws {
        let request = TransactionRequest(from: transaction)
        let _: TransactionResponse = try await networkClient.request(
            endpoint: "/transactions",
            method: "POST",
            body: request,
            token: token
        )
        // Refresh account balance
        _ = try await bankAccountsService.getAccount()
    }
    
    func updateTransaction(_ transaction: Transaction) async throws {
        let request = TransactionRequest(from: transaction)
        let _: TransactionResponse = try await networkClient.request(
            endpoint: "/transactions/\(transaction.id)",
            method: "PUT",
            body: request,
            token: token
        )
        // Refresh account balance
        _ = try await bankAccountsService.getAccount()
    }
    
    func deleteTransaction(id: Int) async throws {
        let _: EmptyResponse = try await networkClient.request(
            endpoint: "/transactions/\(id)",
            method: "DELETE",
            token: token
        )
        // Refresh account balance
        _ = try await bankAccountsService.getAccount()
    }
    
    private func fetchAccounts() async throws -> [BankAccount] {
        return try await networkClient.request(
            endpoint: "/accounts",
            method: "GET",
            token: token
        )
    }
    
    private func fetchCategories() async throws -> [Category] {
        return try await networkClient.request(
            endpoint: "/categories",
            method: "GET",
            token: token
        )
    }
}
