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
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
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
                            
                            Button(action: {
                                locationsStore.remove(loc)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red.opacity(0.8))
                                    .font(.system(size: 16))
                                    .frame(width: 36, height: 36)
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
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    SavedLocationsView(activeTab: .constant(0))
        .environmentObject(LocationsStore())
        .background(Color.black.opacity(0.85))
}
