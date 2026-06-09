import SwiftUI

struct HourlyForecastView: View {
    @StateObject private var viewModel = HourlyForecastViewModel()
    
    var body: some View {
        // TODO: Sprint 3 — implement horizontal or list hourly forecast view
        VStack {
            Text("Hourly Forecast View Stub")
                .padding()
        }
    }
}

#Preview {
    HourlyForecastView()
}
