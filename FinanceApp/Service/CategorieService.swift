import Foundation

final class CategoriesService {
    func getAllCategories() async throws -> [Category] {
        return [
            Category(id: 1, name: "Зарплата", isIncome: true, emoji: "💰"),
            Category(id: 2, name: "Продукты", isIncome: false, emoji: "🛒"),
            Category(id: 3, name: "Кафе", isIncome: false, emoji: "☕️"),
            Category(id: 4, name: "Инвестиции", isIncome: true, emoji: "📈")
        ]
    }

    func getCategories(for direction: Direction) async throws -> [Category] {
        let all = try await getAllCategories()
        return all.filter { $0.direction == direction }
    }
}
