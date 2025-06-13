import Foundation

final class TransactionsFileCache {
    // MARK: - Stored transactions (read-only from outside)
    private(set) var transactions: [Transaction] = []

    // MARK: - Add transaction (prevent duplicates)
    func add(_ transaction: Transaction) {
        guard !transactions.contains(where: { $0.id == transaction.id }) else { return }
        transactions.append(transaction)
    }

    // MARK: - Remove transaction by id
    func remove(id: Int) {
        transactions.removeAll { $0.id == id }
    }

    // MARK: - Save to file
    func save(to fileURL: URL) throws {
        let arrayOfJSONObjects = transactions.map { $0.jsonObject }
        let data = try JSONSerialization.data(withJSONObject: arrayOfJSONObjects, options: [.prettyPrinted])
        try data.write(to: fileURL)
    }

    // MARK: - Load from file
    func load(from fileURL: URL) throws {
        let data = try Data(contentsOf: fileURL)
        let raw = try JSONSerialization.jsonObject(with: data)

        guard let jsonArray = raw as? [[String: Any]] else {
            throw NSError(domain: "TransactionsFileCache", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Invalid JSON structure"
            ])
        }

        transactions = jsonArray.compactMap { Transaction.parse(jsonObject: $0) }
    }
}
