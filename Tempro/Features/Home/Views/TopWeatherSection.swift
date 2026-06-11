import SwiftUI

struct TopWeatherSection: View {
    @ObservedObject var viewModel: HomeViewModel
    let pageIndex: Int
    let totalPages: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text(viewModel.locationName)
                .font(.system(size: 34, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
            
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
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                .padding(.leading, 14)
            
            Text(viewModel.conditionText)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.95))
            
            HStack(spacing: 12) {
                Text(viewModel.maxTemp)
                Text(viewModel.minTemp)
                    .foregroundColor(.white.opacity(0.7))
            }
            .font(.system(size: 20, weight: .medium, design: .rounded))
            .foregroundColor(.white.opacity(0.85))
            .padding(.top, 2)
        }
        .padding(.vertical, 8)
    }
}
