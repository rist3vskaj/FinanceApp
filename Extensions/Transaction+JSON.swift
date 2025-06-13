import Foundation

extension Transaction {
    // MARK: - Model → Foundation object
    var jsonObject: Any {
        var dict: [String: Any] = [:]
        dict["id"] = id
        dict["accountId"] = accountId
        dict["categoryId"] = categoryId
        dict["amount"] = NSDecimalNumber(decimal: amount)
        dict["transactionDate"] = ISO8601DateFormatter().string(from: transactionDate)
        if let comment = comment {
            dict["comment"] = comment
        }
        return dict
    }


    // MARK: - Foundation object → Model
    static func parse(jsonObject: Any) -> Transaction? {
        guard let dict = jsonObject as? [String: Any] else {
            return nil
        }

        guard
            let id = dict["id"] as? Int,
            let accountId = dict["accountId"] as? Int,
            let categoryId = dict["categoryId"] as? Int,
            let amountValue = dict["amount"] as? NSNumber,
            let dateString = dict["transactionDate"] as? String,
            let transactionDate = ISO8601DateFormatter().date(from: dateString)
        else {
            return nil
        }

        let comment = dict["comment"] as? String

        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amountValue.decimalValue,
            transactionDate: transactionDate,
            comment: comment
        )
    }

}
