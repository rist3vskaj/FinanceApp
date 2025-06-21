import Foundation

enum TransactionsFileCacheError: Error {
    case invalidJSONStructure
}

final class TransactionsFileCache {
    private(set) var transactions: [Transaction] = []

    func add(_ transaction: Transaction) {
        guard !transactions.contains(where: { $0.id == transaction.id }) else { return }
        transactions.append(transaction)
    }

    func remove(id: Int) {
        transactions.removeAll { $0.id == id }
    }

    func save(to fileURL: URL) throws {
        let arrayOfJSONObjects = transactions.map { $0.jsonObject }
        let data = try JSONSerialization.data(withJSONObject: arrayOfJSONObjects, options: [.prettyPrinted])
        try data.write(to: fileURL)
    }

    func load(from fileURL: URL) throws {
        let data = try Data(contentsOf: fileURL)
        let raw = try JSONSerialization.jsonObject(with: data)

        guard let jsonArray = raw as? [[String: Any]] else {
            throw TransactionsFileCacheError.invalidJSONStructure
        }

        transactions = jsonArray.compactMap { Transaction.parse(jsonObject: $0) }
    }
}
