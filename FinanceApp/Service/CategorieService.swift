import Foundation

final class CategoriesService: ObservableObject {
    @Published private var categories: [Category] = []
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    func getAllCategories() async throws -> [Category] {
        // INSERT YOUR JWT TOKEN HERE
        let token = "KG8ToQeYtryu7MJ24PIhmdtc"
        
        let categories: [Category] = try await networkClient.request(
            endpoint: "/categories",
            method: "GET",
            token: token
        )
        
        await MainActor.run {
            self.categories = categories
        }
        
        return categories
    }
    
    func getCategories(for direction: Direction) async throws -> [Category] {
        // INSERT YOUR JWT TOKEN HERE
        let token = "KG8ToQeYtryu7MJ24PIhmdtc"
        
        let isIncome = direction == .income
        let categories: [Category] = try await networkClient.request(
            endpoint: "/categories/type/\(isIncome)",
            method: "GET",
            token: token
        )
        
        await MainActor.run {
            self.categories = categories
        }
        
        return categories
    }
}
