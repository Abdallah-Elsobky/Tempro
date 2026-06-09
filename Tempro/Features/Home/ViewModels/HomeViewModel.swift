import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    // TODO: Sprint 3 — implement weather fetching logic
    @Published var weatherData: WeatherResponse? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
}
