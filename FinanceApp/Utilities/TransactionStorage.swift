
import Foundation

protocol TransactionStorage {
    func getAllTransactions() async -> [Transaction]
    func updateTransaction(_ transaction: Transaction) throws
    func deleteTransaction(withId id: Int) throws
    func createTransaction(_ transaction: Transaction) throws
}
