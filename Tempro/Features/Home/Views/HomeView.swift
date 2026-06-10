import SwiftUI

@MainActor
struct HomeView: View {
    @EnvironmentObject var locationsStore: LocationsStore
    @State private var showSearch = false
    @State private var activeTab = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $activeTab) {
                LocationWeatherPageView(fixedLocation: nil)
                    .tag(0)
                
                ForEach(Array(locationsStore.savedLocations.enumerated()), id: \.element.id) { index, loc in
                    LocationWeatherPageView(fixedLocation: loc)
                        .tag(index + 1)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                floatingBottomTabBar
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchView(activeTab: $activeTab)
                .presentationBackground(.ultraThinMaterial)
        }
        .onChange(of: locationsStore.savedLocations) { newLocations in
            if activeTab > newLocations.count {
                activeTab = newLocations.count
            }
        }
    }
    
    private var floatingBottomTabBar: some View {
        HStack {
            Button(action: { }) {
                Image(systemName: "map")
                    .font(.system(size: 21, weight: .regular))
            }
            
            Spacer().frame(width: 40)
            
            Button(action: { showSearch = true }) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 21, weight: .regular))
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
        .padding(.horizontal, 24)
        .safeAreaPadding(.bottom, 10)
    }
}

#Preview {
    HomeView()
        .environmentObject(LocationsStore())
}

struct GlassBackground: View {
    var cornerRadius: CGFloat = 18
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.white.opacity(0.03))
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
            )
    }
}
