import Foundation

enum Direction: String, Codable {
    case income
    case outcome
}

struct Category: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let isIncome: Bool
    let emoji: Character
    
    var direction: Direction {
        isIncome ? .income : .outcome
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case isIncome
        case emoji
    }
    
    init(id: Int, name: String, isIncome: Bool, emoji: Character) {
        self.id = id
        self.name = name
        self.isIncome = isIncome
        self.emoji = emoji
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        isIncome = try container.decode(Bool.self, forKey: .isIncome)
        let emojiString = try container.decode(String.self, forKey: .emoji)
        guard let firstChar = emojiString.first else {
            throw DecodingError.dataCorruptedError(
                forKey: .emoji,
                in: container,
                debugDescription: "Emoji string is empty"
            )
        }
        emoji = firstChar
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(isIncome, forKey: .isIncome)
        try container.encode(String(emoji), forKey: .emoji)
    }
}
