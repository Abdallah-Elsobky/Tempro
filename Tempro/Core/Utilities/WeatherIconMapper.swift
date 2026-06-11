import SwiftUI

struct WeatherIconMapper {
    static func sfSymbol(for code: Int, isDay: Bool = true) -> String {
        switch code {
        case 1000:
            return isDay ? "sun.max.fill" : "moon.stars.fill"
        case 1003:
            return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case 1006:
            return "cloud.fill"
        case 1009:
            return "smoke.fill"
        case 1030:
            return "cloud.fog.fill"
        case 1063:
            return isDay ? "cloud.sun.rain.fill" : "cloud.moon.rain.fill"
        case 1066:
            return "snowflake"
        case 1087:
            return "cloud.bolt.rain.fill"
        case 1135:
            return "fog.fill"
        case 1150, 1153:
            return "cloud.drizzle.fill"
        case 1180, 1183:
            return "cloud.drizzle.fill"
        case 1186, 1189, 1192, 1195:
            return "cloud.heavyrain.fill"
        case 1210, 1213, 1216, 1219, 1222, 1225:
            return "snowflake"
        case 1240, 1243, 1246:
            return "cloud.rain.fill"
        case 1273, 1276, 1279, 1282:
            return "cloud.bolt.rain.fill"
        default:
            return "nosign"
        }
    }
    
    static func conditionColor(for code: Int) -> Color {
        switch code {
        case 1000:
            return .yellow
        case 1003, 1006, 1009:
            return .gray
        case 1030, 1135:
            return .mint
        case 1063, 1150, 1153, 1180, 1183, 1186, 1189, 1192, 1195, 1240, 1243, 1246:
            return .blue
        case 1066, 1210, 1213, 1216, 1219, 1222, 1225:
            return .teal
        case 1087, 1273, 1276, 1279, 1282:
            return .purple
        default:
            return .blue
        }
    }
}
