import SwiftUI

@MainActor
struct HomeView: View {
    @EnvironmentObject var locationsStore: LocationsStore
    @State private var showSearch = false
    @State private var activeTab = 0
    @AppStorage("tempro_use_fahrenheit") private var useFahrenheit = false
    
    @StateObject private var currentViewModel = HomeViewModel()
    @State private var savedViewModels: [UUID: HomeViewModel] = [:]
    
    private var activeViewModel: HomeViewModel {
        if activeTab == 0 {
            return currentViewModel
        }
        let locIndex = activeTab - 1
        guard locIndex >= 0 && locIndex < locationsStore.savedLocations.count else {
            return currentViewModel
        }
        let loc = locationsStore.savedLocations[locIndex]
        return savedViewModels[loc.id] ?? currentViewModel
    }
    
    var body: some View {
        ZStack {
            backgroundLayer
            
            if let error = activeViewModel.errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: error.contains("location") || error.contains("Location") ? "location.slash.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.7))
                        .accessibilityLabel("Error icon")
                    
                    Text(error.contains("location") || error.contains("Location")
                         ? "Could not determine location. Please enable location services in Settings."
                         : "Failed to load weather. Pull to refresh.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    if error.contains("location") || error.contains("Location") {
                        Button(action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Open Settings")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(22)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .frame(minWidth: 44, minHeight: 44)
                        .accessibilityLabel("Open system settings")
                    } else {
                        Button(action: {
                            Task {
                                await activeViewModel.loadWeather()
                            }
                        }) {
                            Text("Retry")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(22)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .frame(minWidth: 44, minHeight: 44)
                        .accessibilityLabel("Retry loading weather data")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        let totalPages = locationsStore.savedLocations.count + 1
                        
                        LocationPillsHeader(activeTab: $activeTab, savedLocations: locationsStore.savedLocations)
                            .padding(.top, 30)
                        
                        TabView(selection: $activeTab) {
                            TopWeatherSection(viewModel: currentViewModel, pageIndex: 0, totalPages: totalPages)
                                .tag(0)
                            
                            ForEach(Array(locationsStore.savedLocations.enumerated()), id: \.element.id) { index, loc in
                                if let vm = savedViewModels[loc.id] {
                                    TopWeatherSection(viewModel: vm, pageIndex: index + 1, totalPages: totalPages)
                                        .tag(index + 1)
                                } else {
                                    Color.clear
                                        .tag(index + 1)
                                }
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 220)
                        
                        ForecastListSection(viewModel: activeViewModel)
                        
                        BottomStatsSection(viewModel: activeViewModel)
                        
                        LifestyleSection(items: activeViewModel.lifestyleItems)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 110)
                }
                .refreshable {
                    await activeViewModel.loadWeather()
                }
            }
            
            VStack {
                Spacer()
                floatingBottomTabBar
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchView(activeTab: $activeTab, savedViewModels: savedViewModels)
                .presentationBackground(.ultraThinMaterial)
        }
        .task {
            syncViewModels()
            for vm in savedViewModels.values {
                Task {
                    await vm.loadWeather()
                }
            }
            await activeViewModel.loadWeather()
        }
        .onChange(of: activeTab) { _ in
            Task {
                await activeViewModel.loadWeather()
            }
        }
        .onChange(of: locationsStore.savedLocations) { newLocations in
            syncViewModels()
            if activeTab > newLocations.count {
                activeTab = newLocations.count
            }
            Task {
                await activeViewModel.loadWeather()
            }
        }
        .overlay {
            if activeViewModel.isLoading {
                LoadingOverlay()
            }
        }
    }
    
    private var backgroundLayer: some View {
        GeometryReader { proxy in
            ZStack {
                Image(activeViewModel.isMorning ? "morning_bg" : "evening_bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                Color.black.opacity(0.3)
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: activeViewModel.isMorning)
    }
    
    private func syncViewModels() {
        let savedIDs = Set(locationsStore.savedLocations.map { $0.id })
        savedViewModels = savedViewModels.filter { savedIDs.contains($0.key) }
        
        for loc in locationsStore.savedLocations {
            if savedViewModels[loc.id] == nil {
                let vm = HomeViewModel(fixedLocation: loc)
                savedViewModels[loc.id] = vm
                Task {
                    await vm.loadWeather()
                }
            }
        }
    }
    
    private var floatingBottomTabBar: some View {
        HStack {
            Button(action: { showSearch = true }) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 21, weight: .regular))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Saved locations list")
        }
        .foregroundColor(.white)
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
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
            .fill(
                LinearGradient(
                    colors: [Color.white.opacity(0.06), Color.white.opacity(0.02)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.18), Color.white.opacity(0.03)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
    }
}
// AmbientAuraView removed for simpler background style

struct LocationPillsHeader: View {
    @Binding var activeTab: Int
    let savedLocations: [SavedLocation]
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            activeTab = 0
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 11))
                            Text("Current")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(activeTab == 0 ? .black : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(activeTab == 0 ? Color.white : Color.white.opacity(0.12))
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(activeTab == 0 ? 0.3 : 0.15), lineWidth: 0.5)
                        )
                    }
                    .id(0)
                    
                    ForEach(Array(savedLocations.enumerated()), id: \.element.id) { index, loc in
                        let tabIndex = index + 1
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                activeTab = tabIndex
                            }
                        }) {
                            Text(loc.name)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(activeTab == tabIndex ? .black : .white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(activeTab == tabIndex ? Color.white : Color.white.opacity(0.12))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(activeTab == tabIndex ? 0.3 : 0.15), lineWidth: 0.5)
                                )
                        }
                        .id(tabIndex)
                    }
                }
                .padding(.horizontal, 16)
            }
            .onChange(of: activeTab) { targetTab in
                withAnimation(.spring()) {
                    scrollProxy.scrollTo(targetTab, anchor: .center)
                }
            }
        }
    }
}
