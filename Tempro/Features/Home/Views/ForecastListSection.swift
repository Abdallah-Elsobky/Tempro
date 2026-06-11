import SwiftUI

struct ForecastListSection: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        let forecastDays = viewModel.forecastDays
        let globalMin = forecastDays.map { $0.day.mintemp_c }.min() ?? 0
        let globalMax = forecastDays.map { $0.day.maxtemp_c }.max() ?? 100
        
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .foregroundColor(.white.opacity(0.55))
                    .font(.system(size: 13, weight: .semibold))
                    .accessibilityLabel("Calendar icon")
                
                Text("3-DAY FORECAST")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.55))
                    .tracking(0.8)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            ForEach(Array(forecastDays.prefix(3).enumerated()), id: \.element.id) { index, day in
                NavigationLink {
                    HourlyForecastView(selectedDay: day, isMorning: viewModel.isMorning)
                } label: {
                    ForecastRowView(
                        day: day,
                        index: index,
                        globalMin: globalMin,
                        globalMax: globalMax,
                        currentTemp: index == 0 ? viewModel.weatherData?.current.temp_c : nil
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Forecast for \(DateHelper.dayLabel(from: day.date, index: index)), high \(HomeViewModel.formatTemp(day.day.maxtemp_c)), low \(HomeViewModel.formatTemp(day.day.mintemp_c))")
                
                if index < min(forecastDays.count, 3) - 1 {
                    Divider()
                        .background(Color.white.opacity(0.15))
                        .padding(.leading, 16)
                }
            }
        }
        .background(GlassBackground())
    }
}

struct ForecastRowView: View {
    let day: ForecastDay
    let index: Int
    let globalMin: Double
    let globalMax: Double
    var currentTemp: Double? = nil
    
    var body: some View {
        HStack(spacing: 0) {
            Text(DateHelper.dayLabel(from: day.date, index: index))
                .font(.system(size: 16, weight: index == 0 ? .bold : .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 84, alignment: .leading)
            
            Image(systemName: WeatherIconMapper.sfSymbol(for: day.day.condition.code, isDay: true))
                .renderingMode(.original)
                .font(.system(size: 22))
                .frame(width: 36, alignment: .center)
                .accessibilityLabel(day.day.condition.text)
            
            Spacer(minLength: 8)
            
            Text(HomeViewModel.formatTemp(day.day.mintemp_c))
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 40, alignment: .trailing)
                .accessibilityValue("Minimum temperature \(HomeViewModel.formatTemp(day.day.mintemp_c))")
            
            TemperatureRangeBar(
                minTemp: day.day.mintemp_c,
                maxTemp: day.day.maxtemp_c,
                globalMin: globalMin,
                globalMax: globalMax,
                currentTemp: currentTemp
            )
            .padding(.horizontal, 8)
            
            Text(HomeViewModel.formatTemp(day.day.maxtemp_c))
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 40, alignment: .trailing)
                .accessibilityValue("Maximum temperature \(HomeViewModel.formatTemp(day.day.maxtemp_c))")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(index == 0 ? Color.white.opacity(0.04) : Color.clear)
        .cornerRadius(12)
        .contentShape(Rectangle())
    }
}

struct TemperatureRangeBar: View {
    let minTemp: Double
    let maxTemp: Double
    let globalMin: Double
    let globalMax: Double
    var currentTemp: Double? = nil
    
    @State private var pulse = false
    
    var body: some View {
        GeometryReader { geo in
            let range = globalMax - globalMin
            let dayRange = maxTemp - minTemp
            let leftOffset = range > 0 ? CGFloat((minTemp - globalMin) / range) * geo.size.width : 0
            let barWidth = range > 0 ? CGFloat(dayRange / range) * geo.size.width : geo.size.width
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.18))
                    .frame(height: 5)
                
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "64D2FF"), Color(hex: "FFD60A")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(barWidth, 8), height: 5)
                    .offset(x: leftOffset)
                
                if let current = currentTemp {
                    let cappedCurrent = max(minTemp, min(maxTemp, current))
                    let pct = dayRange > 0 ? CGFloat((cappedCurrent - minTemp) / dayRange) : 0.5
                    let knobX = leftOffset + pct * (barWidth - 6)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                            .frame(width: 12, height: 12)
                            .scaleEffect(pulse ? 1.5 : 0.9)
                            .opacity(pulse ? 0.0 : 1.0)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 6, height: 6)
                            .shadow(color: .black.opacity(0.3), radius: 1.5)
                    }
                    .frame(width: 12, height: 12)
                    .offset(x: knobX - 3)
                    .frame(maxHeight: .infinity)
                    .onAppear {
                        withAnimation(
                            .easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                        ) {
                            pulse = true
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(width: 80, height: 6)
    }
}
