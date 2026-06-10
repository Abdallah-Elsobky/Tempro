import Foundation

/// Location represents a geographic location name and coordinates.
struct Location: Codable, Identifiable, Sendable {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
}

struct SavedLocation: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let name: String
    let lat: Double
    let lon: Double
}

