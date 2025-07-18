import Foundation

struct Transaction: Identifiable, Equatable {
    let id: Int
    let account: BankAccount
    let category: Category
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    var updatedAt: Date
}

struct TransactionResponse: Codable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case accountId = "account_id"
        case categoryId = "category_id"
        case amount
        case transactionDate = "transaction_date"
        case comment
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct TransactionRequest: Codable {
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    
    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case categoryId = "category_id"
        case amount
        case transactionDate = "transaction_date"
        case comment
    }
    
    init(from transaction: Transaction) {
        self.accountId = transaction.account.id
        self.categoryId = transaction.category.id
        self.amount = transaction.amount
        self.transactionDate = transaction.transactionDate
        self.comment = transaction.comment
    }
}
