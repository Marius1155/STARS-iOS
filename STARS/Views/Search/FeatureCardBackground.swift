//
//  FeatureCardBackground.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 27.08.2024.
//

import SwiftUI

struct FeatureCardBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .foregroundStyle(.gray)
            .opacity(0.1)
    }
}

#Preview {
    FeatureCardBackground()
}
