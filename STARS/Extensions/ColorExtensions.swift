//
//  ColorExtensions.swift
//  STARS
//
//  Created by Marius Gabriel Budai on 02.12.2025.
//

import Foundation
import SwiftUI

extension Color {
    static let blue = Color(red: 44/255, green: 155/255, blue: 185/255)
    static let grayGreen = Color(red: 134/255, green: 219/255, blue: 169/255)
    static let pink = Color(red: 221/255, green: 158/255, blue: 240/255)
    
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if hexSanitized.count != 7 {
            return nil
        }
        
        if hexSanitized.first! != "#" {
            return nil
        }
            
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
    
    /// Returns true if white text should be used on this color, false if black is better
    func prefersWhiteText() -> Bool {
        // Convert Color -> UIColor to extract RGBA
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Relative luminance formula (sRGB)
        func adjust(_ value: CGFloat) -> CGFloat {
            return (value <= 0.03928) ? (value / 12.92) : pow((value + 0.055) / 1.055, 2.4)
        }

        let r = adjust(red)
        let g = adjust(green)
        let b = adjust(blue)

        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b

        // Threshold: if it's dark, use white text
        return luminance < 0.5
    }
    
    func secondaryTextGray() -> Color {
        if self.prefersWhiteText() {
            // Background is dark → white is main → use a lighter gray
            return Color(.systemGray3) // closer to white, softer than pure white
        } else {
            // Background is light → black is main → use a darker gray
            return Color(.systemGray6) // closer to black, softer than pure black
        }
    }
}
