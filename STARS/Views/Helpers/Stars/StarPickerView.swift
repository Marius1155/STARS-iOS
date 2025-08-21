//
//  StarPickerView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 28.08.2024.
//

import SwiftUI

struct StarPickerView: View {
    @Binding var rating: Double // The selected rating
    private let maxRating: Int = 5 // Maximum rating value

    var body: some View {
        HStack {
            ForEach(1...maxRating, id: \.self) { star in
                ZStack {
                    let starType = starTypeFor(star: star)
                    
                    Image(systemName: starType)
                        .foregroundColor(rating >= Double(star) - 0.5 ? .yellow : .gray)
                        .onTapGesture {
                            rating = Double(star)
                        }
                    
                    HStack(spacing: 0) {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                rating = Double(star) - 0.5
                            }
                        
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                rating = Double(star)
                            }
                    }
                }
                .frame(width: 24, height: 24)
            }
        }
    }
    
    private func starTypeFor(star: Int) -> String {
        if rating >= Double(star) {
            return "star.fill"
        } else if rating >= Double(star) - 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

#Preview {
    StarPickerView(rating: .constant(2))
        .environmentObject(DataManager())
}
