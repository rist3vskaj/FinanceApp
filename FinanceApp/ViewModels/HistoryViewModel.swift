import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    // MARK: Inputs
    @Published var start: Date
    @Published var end:   Date

    enum SortOption : String, CaseIterable, Identifiable {
        
        case date = "Дата операции"
        case amount = "Сумма"
        var id : Self {self}
    }
    
    @Published var sortOption: SortOption = .date {
        
        didSet { Task{ await load() }}
    }
    
    // MARK: Outputs
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var total: Decimal = 0
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?

    private let service   = TransactionsService()
    private let direction: Direction

    init(direction: Direction) {
        self.direction = direction
       
        let today = Date()
        let cal   = Calendar.current

      
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

        // initial load
        Task { await load() }
    }

    
    func load() async {
        isLoading = true
        error     = nil

        do {
  
            let all = try await service.getTransactions(
                from: Calendar.current.startOfDay(for: start),
                to:   Calendar.current.date(
                         bySettingHour: 23,
                         minute: 59,
                         second: 59,
                         of: end
                     )!
            )

            let filtered = all.filter { $0.category.direction == direction }
            
            let sorted : [Transaction]
            switch sortOption {
            case .date:
                sorted = filtered.sorted{$0.transactionDate > $1.transactionDate}
            case .amount :
                sorted = filtered.sorted{$0.amount > $1.amount}
                
            }
            
            transactions = sorted
            total        = sorted.reduce(0) { $0 + $1.amount }
        }
        catch let err {
           
            error = err.localizedDescription
        }

        isLoading = false
    }
}
