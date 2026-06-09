import Foundation

/// ForecastDay represents weather forecast details for a single day.
struct ForecastDay: Codable, Identifiable, Sendable {
    // TODO: Sprint 2 — define Codable properties for daily weather forecast
    let id: UUID
    let date: Date
    let maxTemp: Double
    let minTemp: Double
}
