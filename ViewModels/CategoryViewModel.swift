import Foundation
import Combine

@MainActor
final class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = CategoriesService()

    func fetchCategories() async {
        isLoading = true
        errorMessage = nil

        do {
            categories = try await service.getAllCategories()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

