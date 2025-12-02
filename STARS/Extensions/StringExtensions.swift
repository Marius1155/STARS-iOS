//
//  StringExtensions.swift
//  STARS
//
//  Created by Marius Gabriel Budai on 02.12.2025.
//

import Foundation

extension String {
    func optimizeCloudinaryUrl(width: Int, height: Int?) -> String {
        // 1. Safety check
        guard self.contains("cloudinary.com") else { return self }
        
        // 2. Determine target height (default to width if height is not provided, creating a square)
        let targetHeight = height ?? width
        
        // 3. Calculate 3x pixels for Retina screens
        let pixelWidth = width * 3
        let pixelHeight = targetHeight * 3
        
        // 4. Inject 'c_lfill' (Limit Fill) + Dimensions + Auto Quality
        return self.replacingOccurrences(
            of: "/upload/",
            with: "/upload/w_\(pixelWidth),h_\(pixelHeight),c_lfill,q_auto/"
        )
    }
    
    /**
     Cleans a song title by removing featured artist markers (feat., ft., featuring)
     and all text that follows them from a song title.
     
     This implementation covers all major variations of the feature marker:
     - Keywords: feat, feat., ft, ft., featuring (case-insensitive)
     - Enclosure: Parentheses (), Square Brackets [], and Curly Braces {}
     
     Example: "Title {Ft. Artist}" -> "Title"
     */
    func cleaningTitleOfFeatures() -> String {
        // IMPROVED Pattern: Matches optional space, optional enclosure ([(|{]), (keywords), optional enclosure ([)|}]), and everything that follows.
        let pattern = "\\s*[\\(\\[\\{]?(feat\\.?|ft\\.?|featuring)[\\)\\]\\}]?.*$"

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            
            // 1. Replace the matched pattern with an empty string
            let range = NSRange(location: 0, length: self.utf16.count)
            let clean = regex.stringByReplacingMatches(
                in: self,
                options: [],
                range: range,
                withTemplate: ""
            )
            
            // 2. Clean up trailing whitespace and punctuation left behind
            var finalTitle = clean.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Remove any trailing punctuation (e.g., a comma or period right before the feature began)
            if let lastChar = finalTitle.last, ",.:;".contains(lastChar) {
                finalTitle.removeLast()
            }
            
            return finalTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } catch {
            // Should not happen with a static pattern
            print("Regex compilation failed: \(error)")
            return self.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
