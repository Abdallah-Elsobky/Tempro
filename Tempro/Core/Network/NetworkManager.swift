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
            var urlRequest = URLRequest(url: url)
            urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
            return try await AF.request(urlRequest)
                .validate()
                .serializingDecodable(WeatherResponse.self)
                .value
        } catch {
            if let afError = error as? AFError {
                if case .responseValidationFailed(let reason) = afError,
                   case .unacceptableStatusCode(let code) = reason {
                    throw NetworkError.serverError(code)
                }
                // Check for session-level errors (no internet, DNS failure, etc.)
                if case .sessionTaskFailed(let urlError as URLError) = afError {
                    throw NetworkError.noConnection(urlError)
                }
            }
            // Also catch URLError directly if it wasn't wrapped by Alamofire
            if let urlError = error as? URLError,
               urlError.code == .notConnectedToInternet || urlError.code == .timedOut || urlError.code == .networkConnectionLost {
                throw NetworkError.noConnection(urlError)
            }
            throw NetworkError.decodingFailed(error)
        }
    }
    
    func searchLocations(query: String) async throws -> [SearchResult] {
        guard let url = APIEndpoints.search(query: query).url else {
            throw NetworkError.invalidURL
        }
        
        do {
            var urlRequest = URLRequest(url: url)
            urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
            return try await AF.request(urlRequest)
                .validate()
                .serializingDecodable([SearchResult].self)
                .value
        } catch {
            if let afError = error as? AFError {
                if case .responseValidationFailed(let reason) = afError,
                   case .unacceptableStatusCode(let code) = reason {
                    throw NetworkError.serverError(code)
                }
                if case .sessionTaskFailed(let urlError as URLError) = afError {
                    throw NetworkError.noConnection(urlError)
                }
            }
            if let urlError = error as? URLError,
               urlError.code == .notConnectedToInternet || urlError.code == .timedOut || urlError.code == .networkConnectionLost {
                throw NetworkError.noConnection(urlError)
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
    case noConnection(URLError)
    
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
        case .noConnection:
            return "No internet connection. Please check your network and try again."
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

