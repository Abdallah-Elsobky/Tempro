import Foundation
import Combine

@MainActor
final class HourlyForecastViewModel: ObservableObject {
    @Published var hourlyForecasts: [HourlyForecast] = []
    @Published var isLoading: Bool = false
    
    let selectedDay: ForecastDay?
    let isMorning: Bool
    
    init(selectedDay: ForecastDay? = nil, isMorning: Bool = true) {
        self.selectedDay = selectedDay
        self.isMorning = isMorning
    }
}

