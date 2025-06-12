import Foundation

struct Transaction: Codable, Identifiable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    
    // You can still keep CodingKeys if you want backend-compatible naming
    enum CodingKeys: String, CodingKey {
        case id
        case accountId = "account_id"
        case categoryId = "category_id"
        case amount
        case transactionDate = "transaction_date"
        case comment
    }
}
