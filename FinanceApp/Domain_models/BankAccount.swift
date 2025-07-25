import Foundation

struct BankAccount: Codable, Identifiable, Equatable {
    let id: Int
    let userId: Int
    let name: String
    var balance: Decimal
    var currency: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case name
        case balance
        case currency
        case createdAt
        case updatedAt
    }
    init(id: Int, userId: Int, name: String, balance: Decimal, currency: String, createdAt: Date, updatedAt: Date) {
            self.id = id
            self.userId = userId
            self.name = name
            self.balance = balance
            self.currency = currency
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties into temporary variables
        let tempId = try container.decode(Int.self, forKey: .id)
        let tempUserId = try container.decode(Int.self, forKey: .userId)
        let tempName = try container.decode(String.self, forKey: .name)
        
        // Decode balance as String and convert to Decimal
        let balanceString = try container.decode(String.self, forKey: .balance)
        guard let balanceDecimal = Decimal(string: balanceString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .balance,
                in: container,
                debugDescription: "Invalid decimal format"
            )
        }
        
        let tempCurrency = try container.decode(String.self, forKey: .currency)
        
        // Decode dates into temporary variables
        let tempCreatedAt = try Self.decodeDate(from: container, forKey: .createdAt)
        let tempUpdatedAt = try Self.decodeDate(from: container, forKey: .updatedAt)
        
        // Assign to self after all decoding succeeds
        self.id = tempId
        self.userId = tempUserId
        self.name = tempName
        self.balance = balanceDecimal
        self.currency = tempCurrency
        self.createdAt = tempCreatedAt
        self.updatedAt = tempUpdatedAt
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(name, forKey: .name)
        try container.encode(balance.description, forKey: .balance)
        try container.encode(currency, forKey: .currency)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
    
    // Helper function to decode dates with multiple formats
    private static func decodeDate(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) throws -> Date {
        let dateString = try container.decode(String.self, forKey: key)
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // Try different common date formats, including milliseconds
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // ISO 8601 with milliseconds
        if let date = formatter.date(from: dateString) {
            return date
        }
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // ISO 8601 without milliseconds
        if let date = formatter.date(from: dateString) {
            return date
        }
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Basic format
        if let date = formatter.date(from: dateString) {
            return date
        }
        formatter.dateFormat = "yyyy-MM-dd" // Date only
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        // Fallback to Unix timestamp if it's a number
        if let timestamp = TimeInterval(dateString) {
            return Date(timeIntervalSince1970: timestamp)
        }
        
        throw DecodingError.dataCorruptedError(
            forKey: key,
            in: container,
            debugDescription: "Date string '\(dateString)' does not match any expected format."
        )
    }
}
