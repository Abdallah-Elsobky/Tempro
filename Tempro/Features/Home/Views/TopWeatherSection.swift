import SwiftUI

struct TopWeatherSection: View {
    @ObservedObject var viewModel: HomeViewModel
    
    private var textColor: Color {
        viewModel.isMorning ? .black : .white
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(viewModel.locationName)
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
            
            Text(viewModel.currentTemp)
                .font(.system(size: 80, weight: .thin, design: .rounded))
                .foregroundColor(textColor)
                .padding(.leading, 12)
            
            HStack(spacing: 8) {
                Image(systemName: WeatherIconMapper.sfSymbol(for: viewModel.conditionCode, isDay: viewModel.isMorning))
                    .renderingMode(.template)
                    .foregroundColor(textColor)
                    .font(.system(size: 24, weight: .medium))
                
                Text(viewModel.conditionText)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(textColor)
            }
            
            HStack(spacing: 12) {
                Text(viewModel.maxTemp)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(textColor.opacity(0.8))
                
                Text("•")
                    .foregroundColor(textColor.opacity(0.5))
                
                Text(viewModel.minTemp)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(textColor.opacity(0.8))
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
        .shadow(color: viewModel.isMorning ? Color.clear : Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
    }
}

