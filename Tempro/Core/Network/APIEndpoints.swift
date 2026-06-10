import Foundation

/// APIEndpoints defines endpoints for the weathercast services.
enum APIEndpoints {
    static let baseURL = "https://api.weatherapi.com/v1"
    
    case forecast(lat: Double, lon: Double, days: Int)
    case search(query: String)
    
    var url: URL? {
        var components: URLComponents?
        switch self {
        case .forecast(let lat, let lon, let days):
            components = URLComponents(string: "\(APIEndpoints.baseURL)/forecast.json")
            components?.queryItems = [
                URLQueryItem(name: "key", value: APIConstants.apiKey),
                URLQueryItem(name: "q", value: "\(lat),\(lon)"),
                URLQueryItem(name: "days", value: String(days)),
                URLQueryItem(name: "aqi", value: "yes"),
                URLQueryItem(name: "alerts", value: "no")
            ]
        case .search(let query):
            components = URLComponents(string: "\(APIEndpoints.baseURL)/search.json")
            components?.queryItems = [
                URLQueryItem(name: "key", value: APIConstants.apiKey),
                URLQueryItem(name: "q", value: query)
            ]
        }
        return components?.url
    }
}

