import SwiftUI

struct SavedLocationsView: View {
    @EnvironmentObject var locationsStore: LocationsStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SAVED LOCATIONS")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 16)
                .tracking(0.5)
            
            List {
                ForEach(locationsStore.savedLocations) { loc in
                    NavigationLink {
                        LocationWeatherView(location: loc)
                    } label: {
                        HStack {
                            Text(loc.name)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                }
                .onDelete { indexSet in
                    indexSet.forEach { locationsStore.remove(locationsStore.savedLocations[$0]) }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}

#Preview {
    SavedLocationsView()
        .environmentObject(LocationsStore())
        .background(Color.black)
}
