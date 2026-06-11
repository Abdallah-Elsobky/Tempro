import Foundation
import Combine

@MainActor
final class LocationsStore: ObservableObject {
    @Published var savedLocations: [SavedLocation] = []
    
    private let saveKey = "tempro_saved_locations"
    
    init() {
        load()
    }
    
    func add(_ location: SavedLocation) {
        guard !savedLocations.contains(where: { $0.lat == location.lat && $0.lon == location.lon }) else {
            return
        }
        savedLocations.append(location)
        save()
    }
    
    func remove(_ location: SavedLocation) {
        savedLocations.removeAll { $0.id == location.id }
        save()
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(savedLocations)
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return }
        do {
            savedLocations = try JSONDecoder().decode([SavedLocation].self, from: data)
        } catch {
        }
    }
}
