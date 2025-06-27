import XCTest
@testable import FinanceApp

final class TransactionTests: XCTestCase {

    func testTransactionJSONRoundTrip() {
    
        let account = BankAccount(
            id: 1,
            userId: 1,
            name: "Test Account",
            balance: 1000.0,
            currency: "USD",
            createdAt: Date(),
            updatedAt: Date()
        )

        let category = Category(
            id: 2,
            name: "Groceries",
            isIncome: false,
            emoji: "🛒"
        )

        let transaction = Transaction(
            id: 100,
            account: account,
            category: category,
            amount: Decimal(string: "199.99")!,
            transactionDate: ISO8601DateFormatter().date(from: "2025-06-12T13:56:09Z")!,
            comment: "Round-trip test",
            createdAt: Date(),
            updatedAt: Date()
        )

       
        let foundation = transaction.jsonObject
        let restored = Transaction.parse(jsonObject: foundation)

        
        XCTAssertNotNil(restored)
        XCTAssertEqual(restored?.id, transaction.id)
        XCTAssertEqual(restored?.account.id, transaction.account.id)
        XCTAssertEqual(restored?.category.id, transaction.category.id)
        XCTAssertEqual(restored?.amount, transaction.amount)
        XCTAssertEqual(restored?.transactionDate, transaction.transactionDate)
        XCTAssertEqual(restored?.comment, transaction.comment)
    }

    func testTransactionParseFailsOnInvalidData() {
        let brokenJSON: [String: Any] = [
            "id": "not an int",
            "accountId": 1,
            "categoryId": 2,
            "amount": "199.99",
            "transactionDate": "2025-06-12T13:56:09Z",
            "comment": "Invalid"
        ]

        let result = Transaction.parse(jsonObject: brokenJSON)
        XCTAssertNil(result, "Expected nil when parsing invalid json")
    }
}
