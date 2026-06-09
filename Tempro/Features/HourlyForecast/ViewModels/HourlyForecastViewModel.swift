import Foundation
import Combine

@MainActor
final class HourlyForecastViewModel: ObservableObject {
    // TODO: Sprint 3 — implement loading hourly forecast list properties
    @Published var hourlyForecasts: [HourlyForecast] = []
    @Published var isLoading: Bool = false
}
