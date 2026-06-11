import Foundation

struct ForecastDay: Codable, Identifiable, Sendable {
    var id: String { date }
    let date: String
    let day: DayInfo
    let hour: [HourlyForecast]
}

struct DayInfo: Codable, Sendable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let condition: WeatherCondition
}
