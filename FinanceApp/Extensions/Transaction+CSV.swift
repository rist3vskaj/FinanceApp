//import Foundation
//
//extension Transaction {
//    
//    static func fromCSV(_ line: String) -> Transaction? {
//        let components = line.split(separator: ",", omittingEmptySubsequences: false).map { String($0) }
//        
//        guard components.count >= 6 else {
//            return nil
//        }
//
//        guard
//            let id = Int(components[0]),
//            let accountId = Int(components[1]),
//            let categoryId = Int(components[2]),
//            let amount = Decimal(string: components[3]),
//            let date = ISO8601DateFormatter().date(from: components[4])
//        else {
//            return nil
//        }
//
//        let comment = components[5].isEmpty ? nil : components[5]
//
//
//        return Transaction(
//            id: id,
//            account: nil,
//            category: nil,
//            amount: amount,
//            transactionDate: date,
//            comment: comment,
//            createdAt: Date(),
//            updatedAt: Date()
//        )
//    }
//
//    
//    var csvLine: String {
//        let formatter = ISO8601DateFormatter()
//        let dateString = formatter.string(from: transactionDate)
//        let commentField = comment ?? ""
//        return "\(id),\(account.id),\(category.id),\(amount),\(dateString),\(commentField)"
//    }
//}
