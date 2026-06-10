import Foundation
import Combine
import CoreLocation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var weatherData: WeatherResponse? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isMorning: Bool = true
    
    private let networkManager: NetworkManagerProtocol
    private let locationManager: LocationManager
    private let fixedLocation: SavedLocation?
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared,
         fixedLocation: SavedLocation? = nil) {
        self.networkManager = networkManager
        self.locationManager = LocationManager()
        self.fixedLocation = fixedLocation
    }
    
    init(networkManager: NetworkManagerProtocol,
         locationManager: LocationManager,
         fixedLocation: SavedLocation? = nil) {
        self.networkManager = networkManager
        self.locationManager = locationManager
        self.fixedLocation = fixedLocation
    }
    
    func loadWeather() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: WeatherResponse
            if let fixed = fixedLocation {
                response = try await networkManager.fetchWeather(lat: fixed.lat, lon: fixed.lon)
            } else {
                locationManager.requestLocation()
                
                var elapsed = 0.0
                while locationManager.currentLocation == nil && locationManager.locationError == nil && elapsed < 5.0 {
                    try await Task.sleep(nanoseconds: 200_000_000)
                    elapsed += 0.2
                }
                
                if let errorMsg = locationManager.locationError {
                    throw NSError(domain: "LocationError", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMsg])
                }
                
                guard let coordinate = locationManager.currentLocation else {
                    throw NSError(domain: "LocationError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not determine location. Please enable location services in Settings."])
                }
                
                response = try await networkManager.fetchWeather(lat: coordinate.latitude, lon: coordinate.longitude)
            }
            
            self.weatherData = response
            self.isMorning = DateHelper.isMorning()
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    var locationName: String {
        weatherData?.location.name ?? "--"
    }
    
    var currentTemp: String {
        if let temp = weatherData?.current.temp_c {
            return "\(Int(round(temp)))°"
        }
        return "--"
    }
    
    var conditionText: String {
        weatherData?.current.condition.text ?? "--"
    }
    
    var maxTemp: String {
        if let max = weatherData?.forecast.forecastday.first?.day.maxtemp_c {
            return "H: \(Int(round(max)))°"
        }
        return "H: --"
    }
    
    var minTemp: String {
        if let min = weatherData?.forecast.forecastday.first?.day.mintemp_c {
            return "L: \(Int(round(min)))°"
        }
        return "L: --"
    }
    
    var conditionCode: Int {
        weatherData?.current.condition.code ?? 1000
    }
    
    var forecastDays: [ForecastDay] {
        weatherData?.forecast.forecastday ?? []
    }
    
    var visibility: String {
        if let vis = weatherData?.current.vis_km {
            return "\(Int(round(vis))) km"
        }
        return "--"
    }
    
    var humidity: String {
        if let hum = weatherData?.current.humidity {
            return "\(hum)%"
        }
        return "--"
    }
    
    var feelsLike: String {
        if let feels = weatherData?.current.feelslike_c {
            return "\(Int(round(feels)))°"
        }
        return "--"
    }
    
    var pressure: String {
        if let press = weatherData?.current.pressure_mb {
            return "\(Int(round(press))) mb"
        }
        return "--"
    }
    
    var rawFeelsLike: Double { weatherData?.current.feelslike_c ?? 0 }
    var rawHumidity: Double { Double(weatherData?.current.humidity ?? 0) }
    var rawVisibility: Double { weatherData?.current.vis_km ?? 0 }
    var rawPressure: Double { weatherData?.current.pressure_mb ?? 1013 }
}

