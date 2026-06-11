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
    
    static func formatTemp(_ value: Double) -> String {
        let isFahrenheit = UserDefaults.standard.bool(forKey: "tempro_use_fahrenheit")
        let converted = isFahrenheit ? (value * 9/5 + 32) : value
        return "\(Int(round(converted)))°"
    }
    
    var locationName: String {
        weatherData?.location.name ?? "--"
    }
    
    var currentTemp: String {
        if let temp = weatherData?.current.temp_c {
            return HomeViewModel.formatTemp(temp)
        }
        return "--"
    }
    
    var conditionText: String {
        weatherData?.current.condition.text ?? "--"
    }
    
    var maxTemp: String {
        if let max = weatherData?.forecast.forecastday.first?.day.maxtemp_c {
            return "H: \(HomeViewModel.formatTemp(max))"
        }
        return "H: --"
    }
    
    var minTemp: String {
        if let min = weatherData?.forecast.forecastday.first?.day.mintemp_c {
            return "L: \(HomeViewModel.formatTemp(min))"
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
            return HomeViewModel.formatTemp(feels)
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
    
    var lifestyleItems: [LifestyleItem] {
        guard let current = weatherData?.current else {
            return [
                LifestyleItem(iconName: "figure.run", label: "Running: --"),
                LifestyleItem(iconName: "fish", label: "Fishing: --"),
                LifestyleItem(iconName: "figure.hiking", label: "Hiking: --"),
                LifestyleItem(iconName: "hanger", label: "Clothing: --"),
                LifestyleItem(iconName: "medical.thermometer", label: "Cold risk: --"),
                LifestyleItem(iconName: "bandage", label: "Joint pain: --"),
                LifestyleItem(iconName: "sparkles", label: "Stargazing: --"),
                LifestyleItem(iconName: "flag.fill", label: "Golfing: --"),
                LifestyleItem(iconName: "airplane", label: "Flight delays: --")
            ]
        }
        
        let temp = current.temp_c
        let code = current.condition.code
        let feels = current.feelslike_c
        let humidity = current.humidity
        let vis = current.vis_km
        let pressure = current.pressure_mb
        
        let isRainyOrStormy = [1063, 1087, 1180, 1183, 1186, 1189, 1192, 1195, 1240, 1243, 1246, 1273, 1276].contains(code)
        let isSnowy = [1066, 1210, 1213, 1216, 1219, 1222, 1225, 1279, 1282].contains(code)
        let isFoggy = [1030, 1135].contains(code)
        let isOvercast = [1006, 1009].contains(code)
        
        let runningLabel: String
        if isRainyOrStormy || isSnowy {
            runningLabel = "Unsuitable: Rain/Snow"
        } else if temp > 30 {
            runningLabel = "Too hot for running"
        } else if temp < 5 {
            runningLabel = "Too cold for running"
        } else if humidity > 85 {
            runningLabel = "Humid: Hard breathing"
        } else {
            runningLabel = "Great for running"
        }
        
        let fishingLabel: String
        if isRainyOrStormy {
            fishingLabel = "Poor: Storm risk"
        } else if pressure >= 1010 && pressure <= 1020 {
            fishingLabel = "Ideal: Stable pressure"
        } else if pressure < 1005 {
            fishingLabel = "Poor: Low pressure"
        } else {
            fishingLabel = "Fair fishing conditions"
        }
        
        let hikingLabel: String
        if isRainyOrStormy || isSnowy {
            hikingLabel = "Avoid: Storm/Precipitation"
        } else if isFoggy || vis < 5.0 {
            hikingLabel = "Foggy: Poor path visibility"
        } else if temp > 32 {
            hikingLabel = "Too hot for hiking"
        } else if temp < 5 {
            hikingLabel = "Too cold for hiking"
        } else {
            hikingLabel = "Suitable for hiking"
        }
        
        let clothingLabel: String
        if feels > 25 {
            clothingLabel = "Short sleeves & shorts"
        } else if feels > 15 {
            clothingLabel = "Light jacket or sweater"
        } else if feels > 5 {
            clothingLabel = "Wear a warm coat"
        } else {
            clothingLabel = "Heavy winter layers"
        }
        
        let coldRiskLabel: String
        if temp < 5 {
            coldRiskLabel = "Cold risk: High"
        } else if temp < 15 {
            coldRiskLabel = "Cold risk: Moderate"
        } else {
            coldRiskLabel = "Cold risk: Low"
        }
        
        let jointPainLabel: String
        if pressure < 1008 && humidity > 75 {
            jointPainLabel = "Joint pain risk: High"
        } else if temp < 10 {
            jointPainLabel = "Joint pain risk: Moderate"
        } else {
            jointPainLabel = "Joint pain risk: Low"
        }
        
        let stargazingLabel: String
        if isFoggy || isRainyOrStormy {
            stargazingLabel = "Stargazing: Poor (Rain/Fog)"
        } else if isOvercast {
            stargazingLabel = "Stargazing: Poor (Cloudy)"
        } else if code == 1000 && vis >= 10.0 {
            stargazingLabel = "Stargazing: Excellent"
        } else if code == 1003 {
            stargazingLabel = "Stargazing: Fair"
        } else {
            stargazingLabel = "Stargazing: Fair"
        }
        
        let golfingLabel: String
        if isRainyOrStormy || isSnowy {
            golfingLabel = "Avoid: Wet course"
        } else if temp > 35 || temp < 5 {
            golfingLabel = "Poor: Extreme temp"
        } else if vis < 5.0 {
            golfingLabel = "Poor: Low visibility"
        } else {
            golfingLabel = "Golfing: Excellent"
        }
        
        let flightLabel: String
        if code == 1087 || isSnowy || (isRainyOrStormy && vis < 3.0) {
            flightLabel = "Flight delays: High risk"
        } else if isFoggy || vis < 5.0 {
            flightLabel = "Flight delays: Moderate"
        } else {
            flightLabel = "Low flight delays"
        }
        
        return [
            LifestyleItem(iconName: "figure.run", label: runningLabel),
            LifestyleItem(iconName: "fish", label: fishingLabel),
            LifestyleItem(iconName: "figure.hiking", label: hikingLabel),
            LifestyleItem(iconName: "hanger", label: clothingLabel),
            LifestyleItem(iconName: "medical.thermometer", label: coldRiskLabel),
            LifestyleItem(iconName: "bandage", label: jointPainLabel),
            LifestyleItem(iconName: "sparkles", label: stargazingLabel),
            LifestyleItem(iconName: "flag.fill", label: golfingLabel),
            LifestyleItem(iconName: "airplane", label: flightLabel)
        ]
    }
}
