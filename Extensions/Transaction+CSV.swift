import Foundation

extension Transaction {
    
    // MARK: - Parse a CSV line into a Transaction
    static func fromCSV(_ line: String) -> Transaction? {
        let components = line.split(separator: ",", omittingEmptySubsequences: false).map { String($0) }
        
        guard components.count >= 5 else {
            return nil
        }

        guard
            let id = Int(components[0]),
            let accountId = Int(components[1]),
            let categoryId = Int(components[2]),
            let amount = Decimal(string: components[3]),
            let date = ISO8601DateFormatter().date(from: components[4])
        else {
            return nil
        }

        let comment = components.count > 5 ? components[5] : nil

        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: date,
            comment: comment
        )
    }

    // MARK: - Convert a Transaction to a CSV line
    var csvLine: String {
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: transactionDate)
        let commentField = comment ?? ""
        return "\(id),\(accountId),\(categoryId),\(amount),\(dateString),\(commentField)"
    }
}
