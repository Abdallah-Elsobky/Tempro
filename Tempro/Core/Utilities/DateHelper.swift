import Foundation

/// DateHelper contains utility methods for date formatting and manipulation.
struct DateHelper {
    static func isMorning() -> Bool {
        // Returns true if current time is between 05:00 and 18:00 (5:00 AM to 6:00 PM inclusive)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: Date())
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let totalMinutes = hour * 60 + minute
        return totalMinutes >= 300 && totalMinutes <= 1080
    }
    
    static func dayLabel(from dateString: String, index: Int) -> String {
        // index 0 → "Today", index 1 → "Tomorrow", index 2 → third day name
        if index == 0 { return "Today" }
        if index == 1 { return "Tomorrow" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = formatter.date(from: dateString) else { return "" }
        
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    static func hourLabel(from timeString: String) -> String {
        // "2026-06-10 14:00" → "2 PM" or "Now" if current hour
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = formatter.date(from: timeString) else { return "" }
        
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: Date())
        let dateHour = calendar.component(.hour, from: date)
        
        if calendar.isDateInToday(date) && currentHour == dateHour {
            return "Now"
        }
        
        formatter.dateFormat = "h a" // "2 PM"
        return formatter.string(from: date)
    }
}

