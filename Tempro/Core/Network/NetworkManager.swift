import Foundation

protocol NetworkManagerProtocol: Sendable {
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse
    func searchLocations(query: String) async throws -> [SearchResult]
}

final class NetworkManager: NetworkManagerProtocol {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        guard let url = APIEndpoints.forecast(lat: lat, lon: lon, days: 3).url else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
    
    func searchLocations(query: String) async throws -> [SearchResult] {
        guard let url = APIEndpoints.search(query: query).url else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([SearchResult].self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}

enum NetworkError: Error, LocalizedError, Sendable {
    case invalidURL
    case noData
    case decodingFailed(Error)
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL constructed for the request is invalid."
        case .noData:
            return "The server did not return a response."
        case .decodingFailed(let error):
            return "Failed to decode the weather data: \(error.localizedDescription)"
        case .serverError(let code):
            return "The server returned an error status code: \(code)."
        }
    }
}

struct SearchResult: Codable, Identifiable, Sendable {
    let id: Int
    let name: String
    let country: String
    let lat: Double
    let lon: Double
}

