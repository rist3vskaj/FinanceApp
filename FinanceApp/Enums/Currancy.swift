import SwiftUI

enum Currency: String, CaseIterable, Identifiable {
    case RUB, USD, EUR
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .RUB: return "₽ (RUB)"
        case .USD: return "$ (USD)"
        case .EUR: return "€ (EUR)"
        }
    }
}
