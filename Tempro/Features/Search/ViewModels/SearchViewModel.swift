import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    // TODO: Sprint 4 — implement city search query handling and saving locations
    @Published var searchQuery: String = ""
    @Published var searchResults: [Location] = []
    @Published var savedLocations: [Location] = []
    @Published var isLoading: Bool = false
}
