import SwiftUI

struct HourlyForecastView: View {
    @StateObject private var viewModel: HourlyForecastViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(selectedDay: ForecastDay? = nil, isMorning: Bool = true) {
        _viewModel = StateObject(wrappedValue: HourlyForecastViewModel(selectedDay: selectedDay, isMorning: isMorning))
    }
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                Image(viewModel.isMorning ? "morning_bg" : "evening_bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .accessibilityLabel("Weather background")
            }
            .ignoresSafeArea()
            Color.black.opacity(0.3).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                                .accessibilityLabel("Back icon")
                            Text("Weather")
                                .font(.system(size: 17, weight: .regular))
                        }
                        .foregroundColor(viewModel.isMorning ? .black : .white)
                        .frame(minWidth: 44, minHeight: 44)
                    }
                    .accessibilityLabel("Back to main weather screen")
                    
                    Spacer()
                    
                    Text(viewModel.dayTitle)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(viewModel.isMorning ? .black : .white)
                    
                    Spacer()
                    Spacer().frame(width: 70)
                }
                .padding(.horizontal, 16)
                .padding(.top, 60)
                .padding(.bottom, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .foregroundColor(viewModel.isMorning ? .black.opacity(0.55) : .white.opacity(0.55))
                                .font(.system(size: 13, weight: .semibold))
                                .accessibilityLabel("Clock icon")
                            
                            Text("HOURLY FORECAST")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(viewModel.isMorning ? .black.opacity(0.55) : .white.opacity(0.55))
                                .tracking(0.8)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                        .padding(.bottom, 10)
                        
                        Divider()
                            .background(viewModel.isMorning ? Color.black.opacity(0.15) : Color.white.opacity(0.2))
                        
                        let visibleHours = viewModel.visibleHours
                        let isToday = viewModel.dayTitle == "Today"
                        ForEach(Array(visibleHours.enumerated()), id: \.element.id) { index, hour in
                            HourlyRowView(
                                hour: hour,
                                isFirst: index == 0,
                                isToday: isToday,
                                isMorning: viewModel.isMorning
                            )
                            
                            if index < visibleHours.count - 1 {
                                Divider()
                                    .background(viewModel.isMorning ? Color.black.opacity(0.1) : Color.white.opacity(0.15))
                                    .padding(.leading, 16)
                            }
                        }
                    }
                    .background(GlassBackground(cornerRadius: 18))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#if DEBUG
extension ForecastDay {
    static var previewMock: ForecastDay {
        let condition = WeatherCondition(text: "Partly cloudy", icon: "//cdn.weatherapi.com/weather/64x64/day/116.png", code: 1003)
        let dayInfo = DayInfo(maxtemp_c: 28.0, mintemp_c: 18.0, condition: condition)
        
        var hours: [HourlyForecast] = []
        for h in 0..<24 {
            let timeString = String(format: "2026-06-10 %02d:00", h)
            hours.append(HourlyForecast(
                time: timeString,
                temp_c: 20.0 + Double(h % 5),
                condition: condition
            ))
        }
        
        return ForecastDay(date: "2026-06-10", day: dayInfo, hour: hours)
    }
}

#Preview {
    HourlyForecastView(selectedDay: .previewMock, isMorning: true)
}
#endif
