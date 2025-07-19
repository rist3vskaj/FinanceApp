import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case serializationError(Error)
    case unauthorized
    case notFound
    case badRequest
    case conflict
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let statusCode, let message):
            return "HTTP Error \(statusCode): \(message ?? "No message")"
        case .serializationError(let error):
            return "Serialization error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized access"
        case .notFound:
            return "Resource not found"
        case .badRequest:
            return "Bad request"
        case .conflict:
            return "Conflict error"
        case .serverError:
            return "Server error"
        }
    }
}

protocol NetworkClientProtocol {
    func request<T: Decodable, U: Encodable>(
        endpoint: String,
        method: String,
        body: U?,
        token: String
    ) async throws -> T
    
    func request<T: Decodable>(
        endpoint: String,
        method: String,
        token: String
    ) async throws -> T
}

class NetworkClient: NetworkClientProtocol {
    private let baseURL = "https://shmr-finance.ru/api/v1"
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    
    init() {
        self.jsonDecoder = JSONDecoder()
        self.jsonEncoder = JSONEncoder()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        self.jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        self.jsonEncoder.dateEncodingStrategy = .formatted(dateFormatter)
    }
    
    func request<T: Decodable, U: Encodable>(
        endpoint: String,
        method: String,
        body: U?,
        token: String
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            do {
                let data = try await Task.detached { [weak self] in
                    guard let self = self else { throw NetworkError.serverError }
                    return try self.jsonEncoder.encode(body)
                }.value
                request.httpBody = data
            } catch {
                throw NetworkError.serializationError(error)
            }
        }
        
        // 🔹 LOG запроса
        logRequest(request)
        
        return try await performRequest(request)
    }
    
    func request<T: Decodable>(
        endpoint: String,
        method: String,
        token: String
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 🔹 LOG запроса
        logRequest(request)
        
        return try await performRequest(request)
    }
    
    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 🔹 LOG ответа
        logResponse(response, data: data)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200, 201:
            do {
                return try await Task.detached { [weak self] in
                    guard let self = self else { throw NetworkError.serverError }
                    return try self.jsonDecoder.decode(T.self, from: data)
                }.value
            } catch {
                throw NetworkError.serializationError(error)
            }
        case 204:
            guard T.self == EmptyResponse.self else {
                throw NetworkError.invalidResponse
            }
            return EmptyResponse() as! T
        case 400:
            throw NetworkError.badRequest
        case 401:
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.notFound
        case 409:
            throw NetworkError.conflict
        case 500:
            throw NetworkError.serverError
        default:
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, message: nil)
        }
    }
    
    // MARK: - Logging helpers
    
    private func logRequest(_ request: URLRequest) {
        print("📤 [REQUEST] \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
        if let headers = request.allHTTPHeaderFields {
            print("Headers: \(headers)")
        }
        if let body = request.httpBody,
           let json = String(data: body, encoding: .utf8) {
            print("Body: \(json)")
        } else {
            print("Body: <empty>")
        }
    }
    
    private func logResponse(_ response: URLResponse, data: Data) {
        if let httpResponse = response as? HTTPURLResponse {
            print("📥 [RESPONSE] \(httpResponse.statusCode) from \(httpResponse.url?.absoluteString ?? "")")
            print("Headers: \(httpResponse.allHeaderFields)")
            if let json = String(data: data, encoding: .utf8), !json.isEmpty {
                print("Body: \(json)")
            } else {
                print("Body: <empty>")
            }
        } else {
            print("📥 [RESPONSE] Non-HTTP response: \(response)")
        }
    }
}

// Empty response type for 204 No Content
struct EmptyResponse: Codable {}
