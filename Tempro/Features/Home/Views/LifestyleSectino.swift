import SwiftUI

struct LifestyleSection: View {
    let items: [LifestyleItem]
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 20))
                
                Text("Lifestyle")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
            }
            .foregroundColor(.white)
            
            LazyVGrid(columns: columns, spacing: 28) {
                ForEach(items) { item in
                    VStack(spacing: 8) {
                        Image(systemName: item.iconName)
                            .font(.system(size: 26, weight: .regular))
                            .frame(height: 32)
                        
                        Text(item.label)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.06))
                .background(.ultraThinMaterial)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
        )
    }
}

