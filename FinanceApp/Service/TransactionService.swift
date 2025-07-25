// TransactionsService.swift
import Foundation
import SwiftData

final class TransactionsService: ObservableObject {
    private let networkClient: NetworkClientProtocol
    private let bankAccountsService: BankAccountsService
    private let token: String
    private let categoriesService: CategoriesService
    private var currentTask: URLSessionTask?
    private let storage: TransactionStorage
    private let backup: TransactionBackup

    init(networkClient: NetworkClientProtocol = NetworkClient(), token: String, container: ModelContainer) {
        self.networkClient = networkClient
        self.bankAccountsService = BankAccountsService(networkClient: networkClient)
        self.token = token
        self.categoriesService = CategoriesService(networkClient: networkClient) // Assuming CategoriesService exists
        self.storage = try! SwiftDataTransactionStorage(container: container ,accountsService: bankAccountsService, categoriesService: categoriesService)
        self.backup = try! TransactionBackup(container: container)
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
        try storage.createTransaction(transaction)
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
            try storage.updateTransaction(transaction) // Sync with server ID if needed
            _ = try await bankAccountsService.getAccount()
            print("Account balance refreshed")
        } catch {
            backup.addOperation(transaction, action: .create)
            throw error
        }
    }

    func updateTransaction(_ transaction: Transaction) async throws {
        try storage.updateTransaction(transaction)
        let request = TransactionRequest(from: transaction)
        do {
            let _: TransactionCreationResponse = try await networkClient.request(
                endpoint: "/transactions/\(transaction.id)",
                method: "PUT",
                body: request,
                token: token
            )
            _ = try await bankAccountsService.getAccount()
        } catch {
            backup.addOperation(transaction, action: .update)
            throw error
        }
    }

    func deleteTransaction(id: Int) async throws {
        try storage.deleteTransaction(withId: id)
        do {
            let _: EmptyResponse = try await networkClient.request(
                endpoint: "/transactions/\(id)",
                method: "DELETE",
                token: token
            )
            _ = try await bankAccountsService.getAccount()
        } catch {
            if let transaction = try await storage.getAllTransactions().first(where: { $0.id == id }) {
                backup.addOperation(transaction, action: .delete)
            }
            throw error
        }
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

    // Helper to sync backups
    func syncBackups() async throws {
        let unsynced = backup.getUnsyncedOperations()
        for operation in unsynced {
            do {
                switch operation.action {
                case .create:
                    try await createTransaction(operation.transaction)
                case .update:
                    try await updateTransaction(operation.transaction)
                case .delete:
                    try await deleteTransaction(id: operation.transaction.id)
                }
                try backup.clearSyncedOperation(withId: operation.transaction.id)
            } catch {
                print("Failed to sync operation: \(error)")
            }
        }
    }
}
