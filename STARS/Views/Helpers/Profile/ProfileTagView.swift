//
//  ProfileTagView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 24.03.2025.
//

import SwiftUI

struct ProfileTagView: View {
    var tag: String
    
    var body: some View {
        
        if tag != "" {
            Text("@\(tag)")
                .foregroundStyle(.gray)
                .font(.subheadline)
        }
    }
}

#Preview {
    ProfileTagView(tag: "andra115")
}
