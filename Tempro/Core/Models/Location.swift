import Foundation

/// Location represents a geographic location name and coordinates.
struct Location: Codable, Identifiable, Sendable {
    // TODO: Sprint 2 — define Codable properties representing geographic location details
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
}
