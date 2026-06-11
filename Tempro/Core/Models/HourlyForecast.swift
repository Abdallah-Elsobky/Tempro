import Foundation

struct HourlyForecast: Codable, Identifiable, Sendable {
    var id: String { time }
    let time: String
    let temp_c: Double
    let condition: WeatherCondition
}
