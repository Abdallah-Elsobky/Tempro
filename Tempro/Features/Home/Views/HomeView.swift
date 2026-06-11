import SwiftUI

@MainActor
struct HomeView: View {
    @EnvironmentObject var locationsStore: LocationsStore
    @State private var showSearch = false
    @State private var activeTab = 0
    
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
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    let totalPages = locationsStore.savedLocations.count + 1
                    
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
                    .frame(height: 270)
                    .padding(.top, 40)
                    
                    ForecastListSection(viewModel: activeViewModel)
                    
                    BottomStatsSection(viewModel: activeViewModel)
                    
                    LifestyleSection(items: activeViewModel.lifestyleItems)
                    
                    if let error = activeViewModel.errorMessage {
                        errorBanner(error)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 110)
            }
            .refreshable {
                await activeViewModel.loadWeather()
            }
            
            VStack {
                Spacer()
                floatingBottomTabBar
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchView(activeTab: $activeTab)
                .presentationBackground(.ultraThinMaterial)
        }
        .task {
            syncViewModels()
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
    
    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.red.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func syncViewModels() {
        let savedIDs = Set(locationsStore.savedLocations.map { $0.id })
        savedViewModels = savedViewModels.filter { savedIDs.contains($0.key) }
        
        for loc in locationsStore.savedLocations {
            if savedViewModels[loc.id] == nil {
                savedViewModels[loc.id] = HomeViewModel(fixedLocation: loc)
            }
        }
    }
    
    private var floatingBottomTabBar: some View {
        HStack {
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
