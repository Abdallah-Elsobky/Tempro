import SwiftUI

struct SavedLocationsView: View {
    @EnvironmentObject var locationsStore: LocationsStore
    @Binding var activeTab: Int
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
                    HStack {
                        Button(action: {
                            activeTab = index + 1
                            dismiss()
                        }) {
                            HStack {
                                Text(loc.name)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                    )
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

#Preview {
    SavedLocationsView(activeTab: .constant(0))
        .environmentObject(LocationsStore())
        .background(Color.black.opacity(0.85))
}
