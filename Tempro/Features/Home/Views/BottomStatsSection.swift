import SwiftUI

struct BottomStatsSection: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        let columns = [
            GridItem(.flexible(), spacing: 14),
            GridItem(.flexible(), spacing: 14)
        ]
        
        LazyVGrid(columns: columns, spacing: 14) {
            StatCard(
                icon: "thermometer.medium",
                title: "Feels like",
                value: viewModel.feelsLike,
                unit: ""
            ) {
                VStack(alignment: .leading, spacing: 4) {
                    let relative = (viewModel.rawFeelsLike + 10.0) / 55.0
                    let capped = max(0, min(1.0, relative))
                    SliderTrack(progress: capped)
                        .padding(.vertical, 4)
                    
                    Text(viewModel.rawFeelsLike < 15 ? "Wind is making it feel cooler." : "Similar to the actual temperature.")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.75))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            StatCard(
                icon: "humidity",
                title: "Humidity",
                value: String(viewModel.humidity.filter { $0.isNumber }),
                unit: "%"
            ) {
                Text("Dry weather, stay hydrated.")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.75))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxHeight: .infinity, alignment: .bottomLeading)
            }
            
            StatCard(
                icon: "eye.fill",
                title: "Visibility",
                value: String(viewModel.visibility.split(separator: " ").first ?? "10"),
                unit: String(viewModel.visibility.split(separator: " ").last ?? "km")
            ) {
                VStack(alignment: .leading, spacing: 2) {
                    Spacer(minLength: 0)
                    HStack {
                        Text("Low")
                        Spacer()
                        Text("High")
                    }
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
                    
                    SliderTrack(progress: min(viewModel.rawVisibility / 10.0, 1.0))
                        .padding(.bottom, 6)
                    
                    Text(viewModel.rawVisibility >= 10.0 ? "Excellent visibility." : "Light haze reducing visibility.")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.75))
                        .lineLimit(1)
                }
            }
            
            StatCard(
                icon: "info.circle",
                title: "Pressure",
                value: "",
                unit: ""
            ) {
                VStack(spacing: 0) {
                    let relative = (viewModel.rawPressure - 950.0) / 100.0
                    let capped = max(0, min(1.0, relative))
                    
                    DottedPressureGauge(progress: capped, displayValue: String(Int(viewModel.rawPressure)))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 2)
                    
                    Spacer(minLength: 0)
                    
                    Text(viewModel.rawPressure > 1013 ? "Slightly high pressure, comfortable." : "Low atmospheric pressure.")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.75))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

struct StatCard<Footer: View>: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    @ViewBuilder let footer: Footer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .accessibilityLabel("\(title) icon")
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white.opacity(0.6))
            .padding(.bottom, 6)
            
            if !value.isEmpty {
                Group {
                    Text(value)
                        .font(.system(size: 38, weight: .medium, design: .rounded))
                    + Text(unit.isEmpty ? "" : " \(unit)")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                }
                .foregroundColor(.white)
                .lineLimit(1)
                .padding(.bottom, 4)
            }
            
            footer
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .frame(height: 165)
        .background(GlassBackground(cornerRadius: 18))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) details")
        .accessibilityValue("\(value) \(unit)")
    }
}

struct SliderTrack: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geo in
            let pct = CGFloat(max(0, min(progress, 1.0)))
            let knobSize: CGFloat = 6
            let knobX = pct * (geo.size.width - knobSize)
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 4)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: knobSize, height: knobSize)
                    .offset(x: knobX)
            }
            .frame(maxHeight: .infinity)
        }
        .frame(height: 6)
    }
}

struct DottedPressureGauge: View {
    let progress: Double
    let displayValue: String
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: 0.75)
                .stroke(
                    Color.white.opacity(0.25),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [1, 3])
                )
                .rotationEffect(.degrees(135))
            
            GeometryReader { geo in
                let angle = 135.0 + (progress * 270.0)
                let radius = geo.size.width / 2
                let center = CGPoint(x: radius, y: radius)
                let x = center.x + radius * cos(Angle(degrees: angle).radians)
                let y = center.y + radius * sin(Angle(degrees: angle).radians)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 5, height: 5)
                    .position(x: x, y: y)
            }
            
            VStack(spacing: -2) {
                Text(displayValue)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Text("hPa")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .frame(width: 68, height: 68)
    }
}
