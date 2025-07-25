import SwiftData
import Foundation

@Model
class TransactionModel {
    let id: Int
    let accountId: Int
    let categoryId: Int
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    let createdAt: Date
    var updatedAt: Date

    init(id: Int, accountId: Int, categoryId: Int, amount: Decimal, transactionDate: Date, comment: String? = nil, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.accountId = accountId
        self.categoryId = categoryId
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

class SwiftDataTransactionStorage: TransactionStorage {
    private let container: ModelContainer
    private let accountsService: BankAccountsService
    private let categoriesService: CategoriesService

    init(container: ModelContainer, accountsService: BankAccountsService, categoriesService: CategoriesService) {
        self.container = container
        self.accountsService = accountsService
        self.categoriesService = categoriesService
        print("SwiftDataTransactionStorage initialized successfully")    }

    func getAllTransactions() async -> [Transaction] {
        let context = ModelContext(container)
        let fetchDescriptor = FetchDescriptor<TransactionModel>(sortBy: [SortDescriptor(\.transactionDate, order: .reverse)])
        do {
            let models = try context.fetch(fetchDescriptor)
            return try await withThrowingTaskGroup(of: Transaction.self) { group in
                var transactions: [Transaction] = []
                for model in models {
                    group.addTask {
                        let account = try await self.accountsService.getAccount() ?? BankAccount(id: model.accountId, userId: 0, name: "", balance: 0, currency: "", createdAt: Date(), updatedAt: Date())
                        let category = try await self.categoriesService.getCategory(id: model.categoryId) ?? Category(id: model.categoryId, name: "", isIncome: false, emoji: " ")
                        return Transaction(
                            id: model.id,
                            account: account,
                            category: category,
                            amount: model.amount,
                            transactionDate: model.transactionDate,
                            comment: model.comment,
                            createdAt: model.createdAt,
                            updatedAt: model.updatedAt
                        )
                    }
                }
                for try await transaction in group {
                    transactions.append(transaction)
                }
                return transactions
            }
        } catch {
            print("Error fetching transactions: \(error)")
            return []
        }
    }
    
    func updateTransaction(_ transaction: Transaction) throws {
        let context = ModelContext(container)
        let transactionId = transaction.id
        let fetchDescriptor = FetchDescriptor<TransactionModel>(
            predicate: #Predicate<TransactionModel> { model in
                model.id == transactionId
            }
        )
        let models = try context.fetch(fetchDescriptor)
        guard let model = models.first else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Transaction not found"])
        }
        
        model.amount = transaction.amount
        model.transactionDate = transaction.transactionDate
        model.comment = transaction.comment
        model.updatedAt = transaction.updatedAt
        do {
            try context.save()
            print("Transaction updated successfully with ID: \(transactionId)")
        } catch {
            print("Error saving updated transaction: \(error)")
            throw error
        }
    }
    
    func deleteTransaction(withId id: Int) throws {
        let context = ModelContext(container)
        let fetchDescriptor = FetchDescriptor<TransactionModel>(predicate: #Predicate { $0.id == id })
        let models = try context.fetch(fetchDescriptor)
        guard let model = models.first else { throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Transaction not found"]) }
        
        context.delete(model)
        do {
            try context.save()
            print("Transaction deleted successfully with ID: \(id)")
        } catch {
            print("Error deleting transaction: \(error)")
            throw error
        }
    }

    func createTransaction(_ transaction: Transaction) throws {
        let context = ModelContext(container)
        let model = TransactionModel(
            id: transaction.id,
            accountId: transaction.account.id,
            categoryId: transaction.category.id,
            amount: transaction.amount,
            transactionDate: transaction.transactionDate,
            comment: transaction.comment,
            createdAt: transaction.createdAt,
            updatedAt: transaction.updatedAt
        )
        context.insert(model)
        do {
            try context.save()
            print("Transaction created successfully with ID: \(transaction.id)")
        } catch {
            print("Error creating transaction: \(error)")
            throw error
        }
    }
}
