import SwiftUI

/// Reusable top weather display — used if HomeView delegates hero to a subview.
/// Currently the hero is inline in HomeView, but this remains for modularity.
struct TopWeatherSection: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 4) {
            Text(viewModel.locationName)
                .font(.system(size: 32, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
            
            Text(viewModel.currentTemp)
                .font(.system(size: 86, weight: .thin, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
            
            Text(viewModel.conditionText)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.95))
            
            HStack(spacing: 6) {
                Text(viewModel.maxTemp)
                Text(viewModel.minTemp)
            }
            .font(.system(size: 17, weight: .medium, design: .rounded))
            .foregroundColor(.white.opacity(0.85))
            .padding(.top, 2)
        }
        .padding(.vertical, 8)
    }
}
