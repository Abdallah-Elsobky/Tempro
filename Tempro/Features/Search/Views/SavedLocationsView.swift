import SwiftUI

struct SavedLocationsView: View {
    @EnvironmentObject var locationsStore: LocationsStore
    @Binding var activeTab: Int
    var savedViewModels: [UUID: HomeViewModel] = [:]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SAVED LOCATIONS")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 16)
                .tracking(0.5)
            
            List {
                ForEach(Array(locationsStore.savedLocations.enumerated()), id: \.element.id) { index, loc in
                    Button(action: {
                        activeTab = index + 1
                        dismiss()
                    }) {
                        SavedLocationCard(loc: loc, vm: savedViewModels[loc.id])
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .onDelete { indexSet in
                    indexSet.forEach { locationsStore.remove(locationsStore.savedLocations[$0]) }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .background(Color.clear)
    }
}

struct SavedLocationCard: View {
    let loc: SavedLocation
    let vm: HomeViewModel?
    
    var body: some View {
        Group {
            if let vm = vm, vm.weatherData != nil {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(loc.name)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(vm.conditionText)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Text(vm.maxTemp)
                            Text(vm.minTemp)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        Text(vm.currentTemp)
                            .font(.system(size: 38, weight: .light, design: .rounded))
                            .foregroundColor(.white)
                        
                        Image(systemName: WeatherIconMapper.sfSymbol(for: vm.conditionCode, isDay: vm.isMorning))
                            .renderingMode(.original)
                            .font(.system(size: 26))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(GlassBackground(cornerRadius: 18))
            } else {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(loc.name)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Loading weather...")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Spacer()
                    ProgressView()
                        .tint(.white)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(GlassBackground(cornerRadius: 18))
            }
        }
    }
    
// Gradient background helper removed
}

#Preview {
    SavedLocationsView(activeTab: .constant(0), savedViewModels: [:])
        .environmentObject(LocationsStore())
        .background(Color.black.opacity(0.85))
}
