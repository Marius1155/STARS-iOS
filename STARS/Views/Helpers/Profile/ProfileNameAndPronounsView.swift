//
//  ProfileNameAndPronounsView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 24.03.2025.
//

import SwiftUI

struct ProfileNameAndPronounsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var name: String
    var pronouns: String
    
    var body: some View {
        HStack(spacing: 0) {
            if name != "" {
                Text(name)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .font(.headline)
                    .bold()
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            if pronouns != "" {
                Text("(\(pronouns))")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .font(.headline)
                    .fontWeight(.regular)
                    .italic()
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
    }
}

#Preview {
    ProfileNameAndPronounsView(name: "Andra", pronouns: "She/He")
}
