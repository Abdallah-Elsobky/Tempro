//
//  LifestyleSectino.swift
//  Tempro
//
//  Created by Elsobky on 10/06/2026.
//
import SwiftUI

struct LifestyleItem: Identifiable {
    let id = UUID()
    let iconName: String // SF Symbol name or asset image name
    let label: String
}

struct LifestyleSection: View {
    // 1. Grid structure definition: 3 columns with flexible widths
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    // 2. Mock data based exactly on your screenshot
    // Note: Replace these with SF Symbols or your own Asset Catalog names
    private let items = [
        LifestyleItem(iconName: "figure.run", label: "Unsuitable for running"),
        LifestyleItem(iconName: "fish", label: "Not ideal fishing"),
        LifestyleItem(iconName: "figure.hiking", label: "Suitable for hiking"),
        LifestyleItem(iconName: "hanger", label: "Short sleeves"),
        LifestyleItem(iconName: "medical.thermometer", label: "Cold risk: High"),
        LifestyleItem(iconName: "bandage", label: "Arm/Joint pain risk"),
        LifestyleItem(iconName: "sparkles", label: "Stargazing: Fair"),
        LifestyleItem(iconName: "flag.fill", label: "Golfing: Fair"),
        LifestyleItem(iconName: "airplane", label: "Low flight delays")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // Header: Lightbulb + Title
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 20))
                
                Text("Lifestyle")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
            }
            .foregroundColor(.white)
            
            // 3-Column Uniform Grid Layout
            LazyVGrid(columns: columns, spacing: 28) {
                ForEach(items) { item in
                    VStack(spacing: 8) {
                        Image(systemName: item.iconName)
                            .font(.system(size: 26, weight: .regular))
                            .frame(height: 32) // Standardizes icon height alignment
                        
                        Text(item.label)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .lineLimit(2) // Prevents long text from breaking row symmetry
                            .fixedSize(horizontal: false, vertical: true) // Forces proper wrapping
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .padding(20)
        // 3. Glassmorphic Background styling
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.06))
                .background(.ultraThinMaterial)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        // The crisp, clear rim-glow outline border
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
        )
    }
}
