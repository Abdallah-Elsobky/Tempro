import Foundation

/// WeatherResponse represents the top-level weather data API response.
struct WeatherResponse: Codable, Sendable {
    // TODO: Sprint 2 — define Codable properties matching the weather API response
    let current: CurrentWeatherStub
    
    struct CurrentWeatherStub: Codable, Sendable {
        let tempC: Double
        let condition: ConditionStub
    }
    
    struct ConditionStub: Codable, Sendable {
        let text: String
        let icon: String
    }
}
