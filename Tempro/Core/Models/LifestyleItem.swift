import Foundation

struct LifestyleItem: Identifiable, Sendable {
    let id = UUID()
    let iconName: String
    let label: String
}
