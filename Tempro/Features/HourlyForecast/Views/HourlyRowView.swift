import SwiftUI

struct HourlyRowView: View {
    let hour: HourlyForecast
    let isFirst: Bool
    let isToday: Bool
    let isMorning: Bool
    
    private var isDay: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if let date = formatter.date(from: hour.time) {
            let hourComponent = Calendar.current.component(.hour, from: date)
            return hourComponent >= 6 && hourComponent < 18
        }
        return true
    }
    
    var body: some View {
        HStack {
            Text(isFirst && isToday ? "Now" : DateHelper.hourLabel(from: hour.time))
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .frame(width: 70, alignment: .leading)
            
            Spacer()
            
            Image(systemName: WeatherIconMapper.sfSymbol(for: hour.condition.code, isDay: isDay))
                .renderingMode(.original)
                .font(.system(size: 22))
            
            Spacer()
            
            Text("\(Int(round(hour.temp_c)))°")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .frame(width: 50, alignment: .trailing)
        }
        .foregroundColor(isMorning ? .black : .white)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
