import SwiftUI

struct LocationWeatherPageView: View {
    let fixedLocation: SavedLocation?
    let pageIndex: Int
    let totalPages: Int
    @StateObject private var viewModel: HomeViewModel
    
    init(fixedLocation: SavedLocation?, pageIndex: Int = 0, totalPages: Int = 1) {
        self.fixedLocation = fixedLocation
        self.pageIndex = pageIndex
        self.totalPages = totalPages
        _viewModel = StateObject(wrappedValue: HomeViewModel(fixedLocation: fixedLocation))
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
        }
        .task {
            await viewModel.loadWeather()
        }
        .overlay {
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
    }
    
    private var heroSection: some View {
        VStack(spacing: 4) {
            Text(viewModel.locationName)
                .font(.system(size: 34, weight: .medium, design: .rounded))
            
            if totalPages > 1 {
                HStack(spacing: 6) {
                    ForEach(0..<totalPages, id: \.self) { idx in
                        Circle()
                            .fill(idx == pageIndex ? Color.white : Color.white.opacity(0.4))
                            .frame(width: 7, height: 7)
                    }
                }
                .padding(.vertical, 4)
            }
            
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
            ZStack {
                Image(viewModel.isMorning ? "morning_bg" : "evening_bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                Color.black.opacity(0.3)
            }
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
