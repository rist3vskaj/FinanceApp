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
            guard let account = accounts.first(where: { $0.id == response.account.id }),
                  let category = categories.first(where: { $0.id == response.category.id }) else {
                throw NetworkError.notFound
            }
            
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            return Transaction(
                id: response.id,
                account: account,
                category: category,
                amount: Decimal(string: response.amount) ?? 0,
                transactionDate: formatter.date(from: response.transactionDate) ?? Date(),
                comment: response.comment,
                createdAt: formatter.date(from: response.createdAt) ?? Date(),
                updatedAt: formatter.date(from: response.updatedAt) ?? Date()
            )
        }
    }
    
    func getTransactions(from start: Date, to end: Date) async throws -> [Transaction] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let startDate = dateFormatter.string(from: start)
        let endDate = dateFormatter.string(from: end)
        
        let responses: [TransactionResponse] = try await networkClient.request(
            endpoint: "/transactions/account/\(111)/period?startDate=\(startDate)&endDate=\(endDate)",
            method: "GET",
            token: token
        )
        
        let accounts = try await fetchAccounts()
        let categories = try await fetchCategories()
        
        return try responses.map { response in
            guard let account = accounts.first(where: { $0.id == response.account.id }),
                  let category = categories.first(where: { $0.id == response.category.id }) else {
                throw NetworkError.notFound
            }
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            return Transaction(
                id: response.id,
                account: account,
                category: category,
                amount: Decimal(string: response.amount) ?? 0,
                transactionDate: formatter.date(from: response.transactionDate) ?? Date(),
                comment: response.comment,
                createdAt: formatter.date(from: response.createdAt) ?? Date(),
                updatedAt: formatter.date(from: response.updatedAt) ?? Date()
            )
        }
    }
    
    func createTransaction(_ transaction: Transaction) async throws {
        let request = TransactionRequest(from: transaction)
        do {
            print("Sending transaction request: \(request)")
            let response: TransactionCreationResponse = try await networkClient.request(
                endpoint: "/transactions",
                method: "POST",
                body: request,
                token: token
            )
            print("Transaction created with ID: \(response.id)")
            // Refresh account balance
            _ = try await bankAccountsService.getAccount()
            print("Account balance refreshed")
        } catch {
            if let networkError = error as? NetworkError {
                switch networkError {
                case .serverError:
                                    print("Server error: HTTP ")
                default:
                    print("Network error: \(networkError.localizedDescription)")
                }
            } else if let urlError = error as? URLError {
                print("URL error: \(urlError.code.rawValue) - \(urlError.localizedDescription)")
            } else {
                print("Unexpected error creating transaction: \(error)")
            }
            throw error
        }
    }
    
    func updateTransaction(_ transaction: Transaction) async throws {
        let request = TransactionRequest(from: transaction)
        let _: TransactionCreationResponse = try await networkClient.request(
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
