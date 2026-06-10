import Foundation

/// HourlyForecast represents forecast details for a specific hour.
struct HourlyForecast: Codable, Identifiable, Sendable {
    var id: String { time }
    let time: String
    let temp_c: Double
    let condition: WeatherCondition
}

