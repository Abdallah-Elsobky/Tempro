import Foundation
import Combine

@MainActor
final class HourlyForecastViewModel: ObservableObject {
    let selectedDay: ForecastDay?
    let isMorning: Bool
    
    init(selectedDay: ForecastDay? = nil, isMorning: Bool = true) {
        self.selectedDay = selectedDay
        self.isMorning = isMorning
    }
    
    var conditionCode: Int {
        selectedDay?.day.condition.code ?? 1000
    }
    
    var visibleHours: [HourlyForecast] {
        guard let day = selectedDay else { return [] }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let todayString = formatter.string(from: Date())
        
        if day.date == todayString {
            let calendar = Calendar.current
            let currentHour = calendar.component(.hour, from: Date())
            
            return day.hour.filter { hour in
                let hourFormatter = DateFormatter()
                hourFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                hourFormatter.locale = Locale(identifier: "en_US_POSIX")
                if let hourDate = hourFormatter.date(from: hour.time) {
                    let hourVal = calendar.component(.hour, from: hourDate)
                    return hourVal >= currentHour
                }
                return false
            }
        } else {
            return day.hour
        }
    }
    
    var dayTitle: String {
        guard let day = selectedDay else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let todayString = formatter.string(from: Date())
        
        if day.date == todayString {
            return "Today"
        }
        
        if let todayDate = formatter.date(from: todayString),
           let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: todayDate) {
            let tomorrowString = formatter.string(from: nextDay)
            if day.date == tomorrowString {
                return "Tomorrow"
            }
        }
        
        if let date = formatter.date(from: day.date) {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        }
        
        return day.date
    }
}

