import Foundation

final class TransactionsService {
    private let cache = TransactionsFileCache()
    private let fileURL: URL

    init(filename: String = "transactions.json") {
           let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
           self.fileURL = documentsDirectory.appendingPathComponent(filename)

           try? cache.load(from: fileURL)
       }


    func getAllTransactions() async throws -> [Transaction] {
        return cache.transactions
    }

    func getTransactions(from start: Date, to end: Date) async throws -> [Transaction] {
        return cache.transactions.filter {
            $0.transactionDate >= start && $0.transactionDate <= end
        }
    }

    func createTransaction(_ transaction: Transaction) async throws {
        cache.add(transaction)
        try cache.save(to: fileURL)
    }

    func updateTransaction(_ transaction: Transaction) async throws {
        cache.remove(id: transaction.id)
        cache.add(transaction)
        try cache.save(to: fileURL)
    }

    func deleteTransaction(id: Int) async throws {
        cache.remove(id: id)
        try cache.save(to: fileURL)
    }
}
