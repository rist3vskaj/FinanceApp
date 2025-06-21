import Foundation

extension Transaction {
   
    var jsonObject: Any {
        var dict: [String: Any] = [:]
        dict["id"] = id
        dict["accountId"] = account.id
        dict["categoryId"] = category.id
        dict["amount"] = NSDecimalNumber(decimal: amount)
        dict["transactionDate"] = ISO8601DateFormatter().string(from: transactionDate)
        if let comment = comment {
            dict["comment"] = comment
        }
        dict["createdAt"] = ISO8601DateFormatter().string(from: createdAt)
        dict["updatedAt"] = ISO8601DateFormatter().string(from: updatedAt)
        return dict
    }

   
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
            let transactionDate = ISO8601DateFormatter().date(from: dateString),
            let createdAtString = dict["createdAt"] as? String,
            let createdAt = ISO8601DateFormatter().date(from: createdAtString),
            let updatedAtString = dict["updatedAt"] as? String,
            let updatedAt = ISO8601DateFormatter().date(from: updatedAtString)
        else {
            return nil
        }

        let comment = dict["comment"] as? String

      
        let mockAccount = BankAccount(
            id: accountId,
            userId: 0,
            name: "Unknown",
            balance: 0,
            currency: "USD",
            createdAt: createdAt,
            updatedAt: updatedAt
        )

        let mockCategory = Category(
            id: categoryId,
            name: "Unknown",
            isIncome: false,
            emoji: "❓"
        )

        return Transaction(
            id: id,
            account: mockAccount,
            category: mockCategory,
            amount: amountValue.decimalValue,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
