//
//  IntExtensions.swift
//  STARS
//
//  Created by Marius Gabriel Budai on 08.12.2025.
//

import Foundation

extension Int {
    /// Formats the integer into a short string with k, m, b suffixes.
    /// E.g., 1200 -> "1.2k", 12500 -> "13k", 1000000 -> "1m"
    var abbreviatedCount: String {
        let num = Double(self)
        let thousand = 1000.0
        let million = 1_000_000.0
        let billion = 1_000_000_000.0
        
        // Helper to format the value based on the "one digit before dot" rule
        func format(_ value: Double, suffix: String) -> String {
            if value < 10 {
                // Single digit before dot: Display one decimal place (e.g., 1.2k), unless it's .0
                return String(format: "%.1f%@", value, suffix)
                    .replacingOccurrences(of: ".0" + suffix, with: suffix)
            } else {
                // Multiple digits before dot: Round to nearest whole number, no decimals (e.g., 12k)
                return String(format: "%.0f%@", value, suffix)
            }
        }
        
        if num >= billion {
            return format(num / billion, suffix: "b")
        } else if num >= million {
            return format(num / million, suffix: "m")
        } else if num >= thousand {
            return format(num / thousand, suffix: "k")
        } else {
            return "\(self)"
        }
    }
}
