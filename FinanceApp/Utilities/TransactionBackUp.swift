import Foundation
import SwiftData

struct BackupOperation {
    enum Action {
        case create
        case update
        case delete
    }
    let transaction: Transaction
    let action: Action
    let timestamp: Date
}

@Model
class BackupOperationModel {
    let transactionId: Int
    let action: String
    let timestamp: Date

    init(transactionId: Int, action: BackupOperation.Action, timestamp: Date) {
        self.transactionId = transactionId
        self.action = action == .create ? "create" : action == .update ? "update" : "delete"
        self.timestamp = timestamp
    }
}

class TransactionBackup {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
        print("TransactionBackup initialized successfully")
    }

    func addOperation(_ transaction: Transaction, action: BackupOperation.Action) {
        let context = ModelContext(container)
        let backupOp = BackupOperationModel(transactionId: transaction.id, action: action, timestamp: Date())
        context.insert(backupOp)
        try? context.save() // Consider proper error handling
    }

    func getUnsyncedOperations() -> [BackupOperation] {
        let context = ModelContext(container)
        let fetchDescriptor = FetchDescriptor<BackupOperationModel>()
        do {
            let models = try context.fetch(fetchDescriptor)
            return models.map { model in
                BackupOperation(
                    transaction: Transaction(
                        id: model.transactionId,
                        account: BankAccount(id: 0, userId: 0, name: "", balance: 0, currency: "", createdAt: Date(), updatedAt: Date()),
                        category: Category(id: 0, name: "", isIncome: false, emoji: " "),
                        amount: 0,
                        transactionDate: Date(),
                        comment: nil,
                        createdAt: Date(),
                        updatedAt: Date()
                    ),
                    action: model.action == "create" ? .create : model.action == "update" ? .update : .delete,
                    timestamp: model.timestamp
                )
            }
        } catch {
            print("Error fetching backup operations: \(error)")
            return []
        }
    }

    func clearSyncedOperation(withId id: Int) throws {
        let context = ModelContext(container)
        let fetchDescriptor = FetchDescriptor<BackupOperationModel>(predicate: #Predicate { $0.transactionId == id })
        let models = try context.fetch(fetchDescriptor)
        guard let model = models.first else { throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Backup operation not found"]) }
        context.delete(model)
        try context.save()
    }
}
