import Foundation

@MainActor
final class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var searchText: String = ""

    var filteredCategories: [Category] {
        guard !searchText.isEmpty else { return categories }
        
        return categories.filter {
            $0.name.fuzzyMatches(searchText)
        }
    }

    private let service = CategoriesService()

    func fetchCategories() async {
        do {
            categories = try await service.getAllCategories()
        } catch {
            print("Error loading categories:", error)
        }
    }
}

