import Foundation

final class TransactionsService : ObservableObject {
    // MARK: — In-memory cache of sample Transactions
    private var cache: [Transaction] = {
        
        let account = BankAccount(
            id: 1,
            userId: 1,
            name: "Test Account",
            balance: Decimal(string: "1000.00")!,
            currency: "RUB",
            createdAt: Date(),
            updatedAt: Date()
        )
       
        let salaryCat = Category(id: 1, name: "Зарплата", isIncome: true,  emoji: "💰")
        let coffeeCat = Category(id: 2, name: "Кофе",     isIncome: false, emoji: "☕️")
        let gymCat = Category(id: 2, name: "Gym",     isIncome: false, emoji: "💰")
        let cokeCat = Category(id: 2, name: "Coke Zero",     isIncome: false, emoji: "💰")
        
        let now = Date()
        return [
            Transaction(
                id: 1,
                account: account,
                category: salaryCat,
                amount: Decimal(string: "500.00")!,
                transactionDate: now,
                comment: "Mock salary",
                createdAt: now,
                updatedAt: now
            ),
            Transaction(
                id: 2,
                account: account,
                category: coffeeCat,
                amount: Decimal(string: "150.25")!,
                transactionDate: now,
                comment: "Mock coffee",
                createdAt: now,
                updatedAt: now
            ),
            Transaction(
                id: 3,
                account: account,
                category: gymCat,
                amount: Decimal(string: "800.00")!,
                transactionDate: now,
                comment: "Mock gym",
                createdAt: now,
                updatedAt: now
            ),
            Transaction(
                id: 4,
                account: account,
                category: cokeCat,
                amount: Decimal(string: "800.00")!,
                transactionDate: now,
                comment: "Mock coke",
                createdAt: now,
                updatedAt: now
            )
        ]
    }()

    init() { }

   
    func getAllTransactions() async throws -> [Transaction] {
        return cache
    }

   
    func getTransactions(from start: Date, to end: Date) async throws -> [Transaction] {
        return cache.filter {
            $0.transactionDate >= start && $0.transactionDate <= end
        }
    }

    func createTransaction(_ transaction: Transaction) async throws {
        cache.append(transaction)
    }

    
    func updateTransaction(_ transaction: Transaction) async throws {
        if let idx = cache.firstIndex(where: { $0.id == transaction.id }) {
            cache[idx] = transaction
        }
    }


    func deleteTransaction(id: Int) async throws {
        cache.removeAll { $0.id == id }
    }
}
