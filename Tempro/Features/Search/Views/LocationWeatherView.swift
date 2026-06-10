import SwiftUI

struct LocationWeatherView: View {
    let location: SavedLocation
    @StateObject private var viewModel: HomeViewModel
    
    init(location: SavedLocation) {
        self.location = location
        _viewModel = StateObject(wrappedValue: HomeViewModel(fixedLocation: location))
    }
    
    var body: some View {
        HomeView(viewModel: viewModel)
    }
}
