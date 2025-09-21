//
//  StyledSymbol.swift
//  HOMEY Clean
//
//  Styled SF Symbol component with consistent weight and styling
//

import SwiftUI

struct StyledSymbol: View {
    let icon: String
    let weight: Font.Weight
    let size: CGFloat
    let color: Color?
    
    init(
        icon: String,
        weight: Font.Weight = .semibold,
        size: CGFloat = 16,
        color: Color? = nil
    ) {
        self.icon = icon
        self.weight = weight
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: size, weight: weight))
            .foregroundColor(color)
    }
}

// MARK: - Convenience Initializers
extension StyledSymbol {
    /// Standard tab bar icon
    static func tabBar(_ icon: String, color: Color? = nil) -> StyledSymbol {
        StyledSymbol(icon: icon, weight: .semibold, size: 20, color: color)
    }
    
    /// Navigation icon
    static func navigation(_ icon: String, color: Color? = nil) -> StyledSymbol {
        StyledSymbol(icon: icon, weight: .semibold, size: 18, color: color)
    }
    
    /// Button icon
    static func button(_ icon: String, color: Color? = nil) -> StyledSymbol {
        StyledSymbol(icon: icon, weight: .semibold, size: 16, color: color)
    }
    
    /// Small icon
    static func small(_ icon: String, color: Color? = nil) -> StyledSymbol {
        StyledSymbol(icon: icon, weight: .semibold, size: 14, color: color)
    }
}

#Preview {
    VStack(spacing: 20) {
        StyledSymbol.tabBar("person")
        StyledSymbol.navigation("house")
        StyledSymbol.button("plus")
        StyledSymbol.small("star")
    }
    .padding()
}