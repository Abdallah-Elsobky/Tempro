import SwiftUI

struct LifestyleSection: View {
    let items: [LifestyleItem]
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
                    .accessibilityLabel("Tips icon")
                
                Text("LIFESTYLE INDEX")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.55))
                    .tracking(0.8)
            }
            .padding(.horizontal, 4)
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(items) { item in
                    VStack(spacing: 8) {
                        Image(systemName: item.iconName)
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 38, height: 38)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                        
                        Text(item.label)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 6)
                    .frame(maxWidth: .infinity)
                    .frame(height: 105)
                    .background(GlassBackground(cornerRadius: 16))
                }
            }
        }
    }
}
