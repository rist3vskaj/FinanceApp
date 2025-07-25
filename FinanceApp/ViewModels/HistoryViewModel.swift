import Foundation
import SwiftUICore

struct CategorySummary: Identifiable {
  let id: Int
  let category: Category
  let total: Decimal

  var emoji: String { String(category.emoji) }
}

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var start: Date
    @Published var end: Date
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var total: Decimal = 0
    @Published private(set) var summaries: [CategorySummary] = []
    
    enum SortOption: String, CaseIterable, Identifiable {
        case date = "Дата операции"
        case amount = "Сумма"
        var id: Self { self }
    }
    
    @Published var sortOption: SortOption = .date {
        didSet { Task { await load() } }
    }
    
    let service: TransactionsService
    let bankAccountsService : BankAccountsService

    let direction: Direction
    
    init(direction: Direction, txService : TransactionsService, bankAccService : BankAccountsService) {
        self.direction = direction
        self.service = txService
        self.bankAccountsService = bankAccService
        
        let today = Date()
        let cal = Calendar.current
        
        if let e = cal.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: today
        ) {
            self.end = e
        } else {
            self.end = today
        }
        
        if let monthAgo = cal.date(
            byAdding: .month,
            value: -1,
            to: today
        ) {
            self.start = cal.startOfDay(for: monthAgo)
        } else {
            self.start = cal.startOfDay(for: today)
        }
        
        Task { await load() }
    }
    
    func load() async {
        do {
            let all = try await service.getTransactions(
                from: Calendar.current.startOfDay(for: start),
                to: Calendar.current.date(
                    bySettingHour: 23,
                    minute: 59,
                    second: 59,
                    of: end
                )!
            )
            
            let filtered = all.filter { $0.category.direction == direction }
            
            let sorted: [Transaction]
            switch sortOption {
            case .date:
                sorted = filtered.sorted { $0.transactionDate > $1.transactionDate }
            case .amount:
                sorted = filtered.sorted { $0.amount > $1.amount }
            }
            
            transactions = sorted
            total = sorted.reduce(0) { $0 + $1.amount }
            
            let dict = Dictionary(grouping: sorted, by: \.category)
            summaries = dict.map { (cat, txs) in
                CategorySummary(
                    id: cat.id,
                    category: cat,
                    total: txs.map(\.amount).reduce(0, +)
                )
            }
            .sorted { $0.total > $1.total }
            
            _ = try await bankAccountsService.getAccount()
        } catch {
            // Error handling managed by NetworkUIUtil
        }
    }
}
