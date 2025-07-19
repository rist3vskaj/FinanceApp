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

struct TransactionCreationResponse: Codable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case accountId
        case categoryId
        case amount
        case transactionDate
        case comment
        case createdAt
        case updatedAt
    }
}

struct TransactionResponse: Codable {
    let id: Int
    let account: AccountDetails
    let category: CategoryDetails
    let amount: String
    let transactionDate: String
    let comment: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case account
        case category
        case amount
        case transactionDate
        case comment
        case createdAt
        case updatedAt
    }
}

struct AccountDetails: Codable {
    let id: Int
    let name: String
    let balance: String
    let currency: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case balance
        case currency
    }
}

struct CategoryDetails: Codable {
    let id: Int
    let name: String
    let emoji: String
    let isIncome: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case emoji
        case isIncome
    }
}

struct TransactionRequest: Codable {
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String // Changed to String to control formatting
    let comment: String?
    
    enum CodingKeys: String, CodingKey {
        case accountId
        case categoryId
        case amount
        case transactionDate
        case comment
    }
    
    init(from transaction: Transaction) {
        self.accountId = transaction.account.id
        self.categoryId = transaction.category.id
        self.amount = "\(transaction.amount)"
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        self.transactionDate = formatter.string(from: transaction.transactionDate)
        self.comment = transaction.comment ?? ""
    }
}
