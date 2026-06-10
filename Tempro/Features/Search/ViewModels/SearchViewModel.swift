import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [SearchResult] = []
    @Published var isSearching: Bool = false
    @Published var errorMessage: String? = nil
    
    private let networkManager: NetworkManagerProtocol
    private var searchTask: Task<Void, Never>? = nil
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func search() {
        searchTask?.cancel()
        guard searchText.count >= 2 else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        errorMessage = nil
        
        searchTask = Task {
            do {
                try await Task.sleep(nanoseconds: 400_000_000)
                if Task.isCancelled { return }
                
                let results = try await networkManager.searchLocations(query: searchText)
                if Task.isCancelled { return }
                
                self.searchResults = results
                self.isSearching = false
            } catch {
                if Task.isCancelled { return }
                self.errorMessage = error.localizedDescription
                self.isSearching = false
            }
        }
    }
    
    func toSavedLocation(_ result: SearchResult) -> SavedLocation {
        SavedLocation(
            id: UUID(),
            name: "\(result.name), \(result.country)",
            lat: result.lat,
            lon: result.lon
        )
    }
}
