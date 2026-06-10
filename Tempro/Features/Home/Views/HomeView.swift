import SwiftUI

@MainActor
struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var showSearch = false
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }
    
    var body: some View {
        ZStack {
            backgroundLayer
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    heroSection
                        .padding(.top, 40)
                    
                    ForecastListSection(viewModel: viewModel)
                    
                    BottomStatsSection(viewModel: viewModel)
                    
                    LifestyleSection(items: viewModel.lifestyleItems)
                    
                    if let error = viewModel.errorMessage {
                        errorBanner(error)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 110)
            }
            .refreshable {
                await viewModel.loadWeather()
            }
            
            VStack {
                Spacer()
                floatingBottomTabBar
            }
        }
        .task {
            await viewModel.loadWeather()
        }
        .sheet(isPresented: $showSearch) {
            SearchView()
        }
        .overlay {
            if viewModel.isLoading {
                LoadingOverlay()
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

    private var heroSection: some View {
        VStack(spacing: 4) {
            Text(viewModel.locationName)
                .font(.system(size: 34, weight: .medium, design: .rounded))
            
            Text(viewModel.currentTemp)
                .font(.system(size: 96, weight: .thin, design: .rounded))
                .padding(.leading, 14)
            
            Text(viewModel.conditionText)
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
            
            HStack(spacing: 12) {
                Text(viewModel.maxTemp)
                Text(viewModel.minTemp)
                    .foregroundColor(.white.opacity(0.7))
            }
            .font(.system(size: 20, weight: .medium, design: .rounded))
        }
        .foregroundColor(.white)
    }

    private var backgroundLayer: some View {
        GeometryReader { proxy in
            Image(viewModel.isMorning ? "morning_bg" : "evening_bg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
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

