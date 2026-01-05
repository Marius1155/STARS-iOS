//
//  ProjectPreview.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 25.09.2024.
//

import SwiftUI
import SDWebImageSwiftUI
import STARSAPI

struct ProjectPreview: View {
    
    let projectData: (id: String, title: String, starAverage: Double, coverImage: String, primaryColor: String, secondaryColor: String, artists: [(id: String, name: String, position: Int)])
    
    var body: some View {
        VStack {
            if let url = URL(string: projectData.coverImage) {
                WebImage(url: url)
                    .resizable()
                    .frame(width: 148, height: 148)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 2)
            } else {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .frame(width: 148, height: 148)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            Text(projectData.title)
                .bold()
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 148, alignment: .leading)
                .padding(.bottom, -1)
            
            HStack {
                Group {
                    Text(String(format: "%.1f", projectData.starAverage))
                    + Text(Image(systemName: "star.fill"))
                        .foregroundColor(.yellow)
                }
                .padding(.trailing, -7)
                
                Text("•")
                    .bold()
                
                ProjectArtistNameView(artists: projectData.artists)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.leading, -5)
                    .foregroundStyle(.gray)
            }
            .foregroundColor(.gray)
            .font(.caption)
            .frame(width: 148, alignment: .leading)
            .padding(.bottom, 1)
        }
    }
}

#Preview {
    ProjectPreview(projectData: (id: "", title: "Vroom Vroom - EP", starAverage: 0, coverImage: "https://res.cloudinary.com/dt2os6mrt/image/upload/v1766081827/ss9xob3p2huwuzflflhp.jpg", primaryColor: "#000000", secondaryColor: "#14151F", artists: [(id: "", name: "Charli xcx", position: 1)]))
}
