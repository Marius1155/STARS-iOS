//
//  StarView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 28.08.2024.
//

import SwiftUI

struct StarView: View {
    @EnvironmentObject var dataManager: DataManager
    var stars: Double
    var body: some View {
        let (integralPart, fractionalPart) = modf(stars)
        let integralInt: Int = Int(integralPart)
        let leftoverStars:Int = 5 - integralInt
        HStack(spacing: 0) {
            if integralInt > 0 {
                ForEach(1...integralInt, id: \.self) {_ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
            
            if fractionalPart > 0 {
                Image(systemName: "star.leadinghalf.filled")
                    .foregroundColor(.yellow)
            }
            
            if leftoverStars > 0 {
                if fractionalPart > 0 {
                    ForEach(1..<leftoverStars, id: \.self) {_ in
                        Image(systemName: "star")
                            .foregroundColor(.yellow)
                    }
                }
                
                else {
                    ForEach(1...leftoverStars, id: \.self) {_ in
                        Image(systemName: "star")
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
    }
}

#Preview {
    StarView(stars: 3.5)
        .environmentObject(DataManager())
}
