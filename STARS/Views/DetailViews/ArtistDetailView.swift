//
//  ArtistDetailView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 28.08.2024.
//

import SwiftUI
import SDWebImageSwiftUI
import STARSAPI

struct RibbonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let triangleWidth: CGFloat = 20 // Width of the cut-in triangles
        let triangleHeight = rect.height / 2

        // Start at the top-left
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width - triangleWidth, y: triangleHeight))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: triangleWidth, y: triangleHeight))
        path.closeSubpath()

        return path
    }
}

struct ArtistDetailView: View {
    var artistID: String
    
    var body: some View {
        ScrollView {
            Text(artistID)
        
            /*VStack {
                ZStack {
                    Rectangle()
                        .foregroundColor(.accentColor)
                        //.padding(.top, -50)
                        .frame(height: 120)
                        .shadow(radius: 10)
                    
                    Circle()
                        .foregroundColor(.white)
                        //.padding(.top, -50)
                        .frame(height: 330)
                        .shadow(radius: 10)
                    
                    WebImage(url: URL(string: artist.picture))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 256, height: 256)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                        //.padding(.top, -50)
                }
                //.padding(.top, -50)
                
                ZStack {
                    RibbonShape()
                        .fill(Color.accentColor)
                        .frame(width: 350, height: 64)
                        .shadow(radius: 10)
                    
                    VStack {
                        Text(artist.name)
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text(artist.pronouns)
                            .font(.title3)
                            .italic()
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
            }*/
        }
    }
}

#Preview {
    ArtistDetailView(artistID: "1")
}
