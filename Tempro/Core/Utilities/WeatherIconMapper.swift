import Foundation
import SwiftUI

/// WeatherIconMapper maps API weather codes or descriptions to SF Symbols.
struct WeatherIconMapper {
    static func sfSymbol(for code: Int, isDay: Bool = true) -> String {
        // Map common WeatherAPI codes to SF Symbol names
        // e.g., 1000 (Sunny) → "sun.max.fill"
        //        1003 (Partly cloudy) → "cloud.sun.fill"
        //        1183 (Light rain) → "cloud.drizzle.fill"
        //        etc. — cover at least 15 common conditions
        switch code {
        case 1000: // Sunny / Clear
            return isDay ? "sun.max.fill" : "moon.stars.fill"
        case 1003: // Partly cloudy
            return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case 1006: // Cloudy
            return "cloud.fill"
        case 1009: // Overcast
            return "smoke.fill"
        case 1030: // Mist
            return "cloud.fog.fill"
        case 1063: // Patchy rain possible
            return isDay ? "cloud.sun.rain.fill" : "cloud.moon.rain.fill"
        case 1066: // Patchy snow possible
            return "snowflake"
        case 1087: // Thundery outbreaks possible
            return "cloud.bolt.rain.fill"
        case 1135: // Fog
            return "fog.fill"
        case 1150, 1153: // Light drizzle
            return "cloud.drizzle.fill"
        case 1180, 1183: // Patchy light rain / Light rain
            return "cloud.drizzle.fill"
        case 1186, 1189, 1192, 1195: // Moderate / heavy rain
            return "cloud.heavyrain.fill"
        case 1210, 1213, 1216, 1219, 1222, 1225: // Light / moderate / heavy snow
            return "snowflake"
        case 1240, 1243, 1246: // Light / moderate / heavy rain shower
            return "cloud.rain.fill"
        case 1273, 1276, 1279, 1282: // Patchy light/heavy snow/rain with thunder
            return "cloud.bolt.rain.fill"
        default:
            return "nosign"
        }
    }
    
    static func conditionColor(for code: Int) -> Color {
        // Returns a subtle accent color per condition
        switch code {
        case 1000: // Sunny
            return .yellow
        case 1003, 1006, 1009: // Cloudy
            return .gray
        case 1030, 1135: // Mist/Fog
            return .mint
        case 1063, 1150, 1153, 1180, 1183, 1186, 1189, 1192, 1195, 1240, 1243, 1246: // Rain
            return .blue
        case 1066, 1210, 1213, 1216, 1219, 1222, 1225: // Snow
            return .teal
        case 1087, 1273, 1276, 1279, 1282: // Thunder
            return .purple
        default:
            return .blue
        }
    }
}

