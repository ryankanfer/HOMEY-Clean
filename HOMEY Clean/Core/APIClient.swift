   import Foundation
import Combine

// MARK: - HTTP Method

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - API Client Protocol

protocol APIClientProtocol {
    func request(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        headers: [String: String]?
    ) -> AnyPublisher<Data, Error>
}

// MARK: - API Client Implementation

class APIClient: APIClientProtocol {
    static let shared = APIClient()
    
    private let baseURL: URL
    private let session: URLSession
    private let defaultHeaders: [String: String]
    
    init(baseURL: String = "https://api.homey.com",
         session: URLSession = .shared,
         defaultHeaders: [String: String] = [:]) {
        
        self.baseURL = URL(string: baseURL)!
        self.session = session
        self.defaultHeaders = defaultHeaders
    }
    
    func request(
        endpoint: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil
    ) -> AnyPublisher<Data, Error> {
        
        guard let url = buildURL(endpoint: endpoint, parameters: method == .GET ? parameters : nil) else {
            return Fail(error: APIClientError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Add default headers
        for (key, value) in defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add custom headers
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Add body for non-GET requests
        if method != .GET, let parameters = parameters {
            do {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            } catch {
                return Fail(error: APIClientError.encodingError(error))
                    .eraseToAnyPublisher()
            }
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIClientError.invalidResponse
                }
                
                guard 200...299 ~= httpResponse.statusCode else {
                    // Try to decode error message from response
                    if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let message = errorData["message"] as? String {
                        throw APIClientError.serverError(httpResponse.statusCode, message)
                    }
                    throw APIClientError.serverError(httpResponse.statusCode, "Request failed")
                }
                
                return data
            }
            .eraseToAnyPublisher()
    }
    
    private func buildURL(endpoint: String, parameters: [String: Any]?) -> URL? {
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            return nil
        }
        
        guard let parameters = parameters, !parameters.isEmpty else {
            return url
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = parameters.compactMap { key, value in
            URLQueryItem(name: key, value: "\(value)")
        }
        
        return components?.url
    }
}

// MARK: - API Client Error

enum APIClientError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case encodingError(Error)
    case serverError(Int, String)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .encodingError(let error):
            return "Encoding error: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Mock API Client for Testing

class MockAPIClient: APIClientProtocol {
    private let delay: TimeInterval
    private var mockResponses: [String: Result<Data, Error>] = [:]
    
    init(delay: TimeInterval = 1.0) {
        self.delay = delay
        setupMockResponses()
    }
    
    func request(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil
    ) -> AnyPublisher<Data, Error> {
        
        let key = "\(method.rawValue) \(endpoint)"
        
        if let mockResponse = mockResponses[key] {
            return mockResponse.publisher
                .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        // Default mock response
        let defaultResponse = mockDefaultResponse(for: endpoint)
        return Just(defaultResponse)
            .setFailureType(to: Error.self)
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func setMockResponse(for endpoint: String, method: HTTPMethod, response: Result<Data, Error>) {
        let key = "\(method.rawValue) \(endpoint)"
        mockResponses[key] = response
    }
    
    private func setupMockResponses() {
        // Mock property listings response
        let listingsResponse = PropertyListingsResponse(
            listings: PropertyListing.sampleListings,
            total: PropertyListing.sampleListings.count,
            hasMore: false
        )
        
        if let data = try? JSONEncoder().encode(listingsResponse) {
            setMockResponse(
                for: "/api/v1/properties/search",
                method: .GET,
                response: .success(data)
            )
        }
        
        // Mock neighborhood data response
        let neighborhoodData = NeighborhoodData(
            name: "Flatiron",
            averagePrice: 5200,
            priceRange: ScoutPriceRange(min: 3000, max: 8500),
            demographics: Demographics(
                averageAge: 32.5,
                medianIncome: 95000,
                populationDensity: 15000
            ),
            amenities: ["Restaurants", "Shopping", "Parks", "Transit"],
            transitScore: 95,
            walkScore: 88,
            bikeScore: 72
        )
        
        if let data = try? JSONEncoder().encode(neighborhoodData) {
            setMockResponse(
                for: "/api/v1/neighborhoods/lookup",
                method: .GET,
                response: .success(data)
            )
        }
    }
    
    private func mockDefaultResponse(for endpoint: String) -> Data {
        let defaultResponse = ["message": "Mock response for \(endpoint)"]
        return try! JSONSerialization.data(withJSONObject: defaultResponse)
    }
}

// MARK: - Extensions

extension Result {
    var publisher: AnyPublisher<Success, Failure> {
        switch self {
        case .success(let value):
            return Just(value)
                .setFailureType(to: Failure.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}
