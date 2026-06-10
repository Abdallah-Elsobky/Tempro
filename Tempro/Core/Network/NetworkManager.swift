import Foundation
import Alamofire

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
        
        do {
            return try await AF.request(url)
                .validate()
                .serializingDecodable(WeatherResponse.self)
                .value
        } catch {
            if let afError = error as? AFError {
                if case .responseValidationFailed(let reason) = afError,
                   case .unacceptableStatusCode(let code) = reason {
                    throw NetworkError.serverError(code)
                }
            }
            throw NetworkError.decodingFailed(error)
        }
    }
    
    func searchLocations(query: String) async throws -> [SearchResult] {
        guard let url = APIEndpoints.search(query: query).url else {
            throw NetworkError.invalidURL
        }
        
        do {
            return try await AF.request(url)
                .validate()
                .serializingDecodable([SearchResult].self)
                .value
        } catch {
            if let afError = error as? AFError {
                if case .responseValidationFailed(let reason) = afError,
                   case .unacceptableStatusCode(let code) = reason {
                    throw NetworkError.serverError(code)
                }
            }
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

