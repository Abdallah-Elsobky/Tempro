import Foundation

/// WeatherIconMapper maps API weather codes or descriptions to SF Symbols.
struct WeatherIconMapper {
    // TODO: Sprint 2 — implement icon mapping rules for SF Symbols
    static func systemIconName(for code: Int) -> String {
        return "sun.max"
    }
}
