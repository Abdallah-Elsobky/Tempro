import SwiftUI

struct ForecastListSection: View {
    @ObservedObject var viewModel: HomeViewModel
    
    private var textColor: Color {
        viewModel.isMorning ? .black : .white
    }
    
    var body: some View {
        let forecastDays = viewModel.forecastDays
        let globalMin = forecastDays.map { $0.day.mintemp_c }.min() ?? 0
        let globalMax = forecastDays.map { $0.day.maxtemp_c }.max() ?? 100
        
        VStack(alignment: .leading, spacing: 10) {
            // Section header
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(textColor.opacity(0.6))
                    .font(.system(size: 12, weight: .semibold))
                
                Text("3-DAY FORECAST")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(textColor.opacity(0.6))
                    .tracking(1.0)
            }
            .padding(.horizontal, 4)
            .padding(.top, 4)
            
            // Forecast List Card
            VStack(spacing: 0) {
                ForEach(Array(forecastDays.prefix(3).enumerated()), id: \.element.id) { index, day in
                    NavigationLink {
                        HourlyForecastView(selectedDay: day, isMorning: viewModel.isMorning)
                    } label: {
                        ForecastRowView(
                            day: day,
                            index: index,
                            isMorning: viewModel.isMorning,
                            globalMin: globalMin,
                            globalMax: globalMax
                        )
                    }
                    .buttonStyle(.plain)
                    
                    if index < min(forecastDays.count, 3) - 1 {
                        Divider()
                            .background(textColor.opacity(0.15))
                            .padding(.leading, 56) // Inset divider to align with labels
                    }
                }
            }
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(viewModel.isMorning ? 0.1 : 0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(viewModel.isMorning ? 0.03 : 0.1), radius: 8, x: 0, y: 4)
        }
    }
}

struct ForecastRowView: View {
    let day: ForecastDay
    let index: Int
    let isMorning: Bool
    let globalMin: Double
    let globalMax: Double
    
    private var textColor: Color {
        isMorning ? .black : .white
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Day label
            Text(DateHelper.dayLabel(from: day.date, index: index))
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(textColor)
                .frame(width: 90, alignment: .leading)
            
            // Icon
            Image(systemName: WeatherIconMapper.sfSymbol(for: day.day.condition.code, isDay: true))
                .renderingMode(.original)
                .font(.system(size: 20))
                .frame(width: 32, alignment: .center)
            
            Spacer()
            
            // Min Temp
            Text("\(Int(round(day.day.mintemp_c)))°")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(textColor.opacity(0.6))
                .frame(width: 30, alignment: .trailing)
            
            // Temperature Range bar
            TemperatureRangeBar(
                minTemp: day.day.mintemp_c,
                maxTemp: day.day.maxtemp_c,
                globalMin: globalMin,
                globalMax: globalMax,
                isMorning: isMorning
            )
            
            // Max Temp
            Text("\(Int(round(day.day.maxtemp_c)))°")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(textColor)
                .frame(width: 30, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .contentShape(Rectangle()) // Make the whole row area clickable
    }
}

struct TemperatureRangeBar: View {
    let minTemp: Double
    let maxTemp: Double
    let globalMin: Double
    let globalMax: Double
    let isMorning: Bool
    
    var body: some View {
        GeometryReader { geo in
            let range = globalMax - globalMin
            let dayRange = maxTemp - minTemp
            
            let leftOffset = range > 0 ? CGFloat((minTemp - globalMin) / range) * geo.size.width : 0
            let barWidth = range > 0 ? CGFloat(dayRange / range) * geo.size.width : geo.size.width
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(isMorning ? Color.black.opacity(0.08) : Color.white.opacity(0.15))
                    .frame(height: 4)
                
                Capsule()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "4A90E2"), Color(hex: "F5A623")]),
                        startPoint: .leading,
                        endPoint: .trailing
                      ))
                    .frame(width: max(barWidth, 8), height: 4)
                    .offset(x: leftOffset)
            }
            .frame(maxHeight: .infinity)
        }
        .frame(width: 80, height: 4)
    }
}
