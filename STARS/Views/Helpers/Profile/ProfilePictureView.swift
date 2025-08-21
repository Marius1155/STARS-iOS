//
//  ProfilePictureView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 24.03.2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfilePictureView: View {
    var pictureURL: String
    var diameter: Double
    
    var body: some View {
        if pictureURL != "" {
            WebImage(url: URL(string: pictureURL))
                .resizable()
                .scaledToFill()
                .frame(width: diameter, height: diameter)
                .clipShape(Circle())
        }
        else {
            Image(systemName: "person.circle")
                .resizable()
                .scaledToFill()
                .frame(width: diameter, height: diameter)
                .clipShape(Circle())
        }
    }
}

#Preview {
    ProfilePictureView(pictureURL: "https://firebasestorage.googleapis.com:443/v0/b/fir-8a33f.appspot.com/o/profile_pictures%2FPuAHWOG22FdfzyBqgxb69Xxmbat2.jpg?alt=media&token=8decb0c4-eefe-40a0-9139-684a9d9da5bd", diameter: 64)
}
