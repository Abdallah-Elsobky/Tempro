import SwiftUI

struct LocationWeatherView: View {
    let location: SavedLocation
    
    var body: some View {
        LocationWeatherPageView(fixedLocation: location)
    }
}
