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
    
    private var textColor: Color {
        viewModel.isMorning ? .black : .white
    }
    
    var body: some View {
        ZStack {
            backgroundLayer
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    TopWeatherSection(viewModel: viewModel)
                    
                    ForecastListSection(viewModel: viewModel)
                    
                    BottomStatsSection(viewModel: viewModel)
                    
                    if let error = viewModel.errorMessage {
                        errorView(error)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 64)
                .padding(.bottom, 40)
            }
            .refreshable {
                await viewModel.loadWeather()
            }
        }
        .ignoresSafeArea()
        .task {
            await viewModel.loadWeather()
        }
        .overlay {
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSearch = true
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(textColor)
                }
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchView()
        }
    }
    
    private var backgroundLayer: some View {
        ZStack {
            if viewModel.isMorning {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "4A90E2"), Color(hex: "50E3C2"), Color(hex: "FFD89B")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                Image("morning_bg")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.8)
            } else {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "0B132B"), Color(hex: "1C2541"), Color(hex: "3A506B")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                Image("evening_bg")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.6)
            }
        }
        .ignoresSafeArea()
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundColor(.orange)
            
            Text(message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
            
            Button {
                Task {
                    await viewModel.loadWeather()
                }
            } label: {
                Text("Retry")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    HomeView()
}
