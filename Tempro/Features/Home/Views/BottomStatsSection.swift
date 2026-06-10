import SwiftUI

struct BottomStatsSection: View {
    @ObservedObject var viewModel: HomeViewModel
    
    private var textColor: Color {
        viewModel.isMorning ? .black : .white
    }
    
    var body: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        
        LazyVGrid(columns: columns, spacing: 12) {
            // Feels Like
            StatTile(
                icon: "thermometer.medium",
                title: "FEELS LIKE",
                value: viewModel.feelsLike,
                isMorning: viewModel.isMorning
            ) {
                let relative = (viewModel.rawFeelsLike + 10.0) / 55.0
                let capped = max(0, min(1.0, relative))
                LinearMeter(value: capped, maxValue: 1.0, isMorning: viewModel.isMorning)
                    .padding(.top, 4)
                
                Text(viewModel.rawFeelsLike < 15 ? "Wind is making it feel cooler." : "Similar to the actual temp.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(textColor.opacity(0.6))
                    .padding(.top, 4)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            // Humidity
            StatTile(
                icon: "humidity",
                title: "HUMIDITY",
                value: viewModel.humidity,
                isMorning: viewModel.isMorning
            ) {
                HStack(spacing: 8) {
                    CircularProgressRing(progress: viewModel.rawHumidity / 100.0, isMorning: viewModel.isMorning)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Dew point")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(textColor.opacity(0.6))
                        let dp = viewModel.rawFeelsLike - ((100.0 - viewModel.rawHumidity) / 5.0)
                        Text("\(Int(round(dp)))°")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(textColor)
                    }
                }
                .padding(.top, 4)
            }
            
            // Visibility
            StatTile(
                icon: "eye",
                title: "VISIBILITY",
                value: viewModel.visibility,
                isMorning: viewModel.isMorning
            ) {
                LinearMeter(value: viewModel.rawVisibility, maxValue: 10.0, isMorning: viewModel.isMorning)
                    .padding(.top, 4)
                
                Text(viewModel.rawVisibility >= 10.0 ? "Perfect clear view." : "Light haze or fog.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(textColor.opacity(0.6))
                    .padding(.top, 4)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            // Pressure
            StatTile(
                icon: "barometer",
                title: "PRESSURE",
                value: viewModel.pressure,
                isMorning: viewModel.isMorning
            ) {
                HStack(spacing: 8) {
                    let relative = (viewModel.rawPressure - 950.0) / 100.0
                    let capped = max(0, min(1.0, relative))
                    ArcGauge(progress: capped, isMorning: viewModel.isMorning)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.rawPressure > 1013 ? "High" : "Low")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(textColor)
                        Text("Atmospheric")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(textColor.opacity(0.6))
                    }
                }
                .padding(.top, 4)
            }
        }
    }
}

struct StatTile<Content: View>: View {
    let icon: String
    let title: String
    let value: String
    let isMorning: Bool
    @ViewBuilder let content: Content
    
    private var textColor: Color {
        isMorning ? .black : .white
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(textColor.opacity(0.5))
                    .font(.system(size: 12, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(textColor.opacity(0.5))
                    .tracking(0.5)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .medium, design: .rounded))
                .foregroundColor(textColor)
                .padding(.top, 2)
            
            Spacer(minLength: 0)
            
            content
        }
        .padding(14)
        .frame(minHeight: 142)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(isMorning ? 0.1 : 0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(isMorning ? 0.03 : 0.1), radius: 8, x: 0, y: 4)
    }
}

struct CircularProgressRing: View {
    let progress: Double
    let isMorning: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(isMorning ? Color.black.opacity(0.06) : Color.white.opacity(0.12), lineWidth: 4)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "50E3C2"), Color(hex: "4A90E2")]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(Angle(degrees: -90))
                .animation(.easeOut(duration: 0.6), value: progress)
        }
        .frame(width: 44, height: 44)
    }
}

struct LinearMeter: View {
    let value: Double
    let maxValue: Double
    let isMorning: Bool
    
    var body: some View {
        GeometryReader { geo in
            let pct = maxValue > 0 ? CGFloat(min(value, maxValue) / maxValue) : 0
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(isMorning ? Color.black.opacity(0.06) : Color.white.opacity(0.12))
                    .frame(height: 4)
                
                Circle()
                    .fill(isMorning ? Color.black : Color.white)
                    .frame(width: 8, height: 8)
                    .offset(x: pct * (geo.size.width - 8))
            }
            .frame(maxHeight: .infinity)
        }
        .frame(height: 8)
    }
}

struct ArcGauge: View {
    let progress: Double
    let isMorning: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.15, to: 0.85)
                .stroke(isMorning ? Color.black.opacity(0.06) : Color.white.opacity(0.12), style: StrokeStyle(lineWidth: 4, lineCap: .round))
            
            Circle()
                .trim(from: 0.15, to: CGFloat(0.15 + (0.85 - 0.15) * min(progress, 1.0)))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "FFD89B"), Color(hex: "F5A623")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .animation(.easeOut(duration: 0.6), value: progress)
        }
        .rotationEffect(Angle(degrees: 90))
        .frame(width: 44, height: 44)
    }
}
