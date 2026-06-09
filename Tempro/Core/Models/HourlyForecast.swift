import Foundation

/// HourlyForecast represents forecast details for a specific hour.
struct HourlyForecast: Codable, Identifiable, Sendable {
    // TODO: Sprint 2 — define Codable properties for hourly weather forecast
    let id: UUID
    let time: Date
    let temperature: Double
    let iconName: String
}
