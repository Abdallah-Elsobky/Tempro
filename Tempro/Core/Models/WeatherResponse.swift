import Foundation

/// WeatherResponse represents the top-level weather data API response.
struct WeatherResponse: Codable, Sendable {
    let location: LocationInfo
    let current: CurrentWeather
    let forecast: ForecastContainer
}

struct LocationInfo: Codable, Sendable {
    let name: String
    let lat: Double
    let lon: Double
    let localtime: String
}

struct CurrentWeather: Codable, Sendable {
    let temp_c: Double
    let feelslike_c: Double
    let humidity: Int
    let vis_km: Double
    let pressure_mb: Double
    let condition: WeatherCondition
}

struct WeatherCondition: Codable, Sendable {
    let text: String
    let icon: String
    let code: Int
}

struct ForecastContainer: Codable, Sendable {
    let forecastday: [ForecastDay]
}

