import SwiftUI

struct HourlyForecastView: View {
    @StateObject private var viewModel: HourlyForecastViewModel
    
    init(selectedDay: ForecastDay? = nil, isMorning: Bool = true) {
        _viewModel = StateObject(wrappedValue: HourlyForecastViewModel(selectedDay: selectedDay, isMorning: isMorning))
    }
    
    var body: some View {
        VStack {
            Text("Hourly Forecast View Stub")
                .padding()
        }
    }
}

#Preview {
    HourlyForecastView()
}

