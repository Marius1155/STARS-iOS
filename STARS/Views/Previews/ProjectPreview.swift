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
    
    let projectID: String
    
    @State private var project: STARSAPI.GetProjectPreviewQuery.Data.Project? = nil
    @State private var imageURL: URL? = nil
    @State private var artistsIDs: [String] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if let url = imageURL {
                WebImage(url: url)
                    .resizable()
                    .frame(width: 148, height: 148)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 2)
            } else if isLoading {
                ProgressView()
                    .frame(width: 148, height: 148)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                // Fallback empty placeholder
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .frame(width: 148, height: 148)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            if let project = project {
                Text(project.title)
                    .bold()
                    .font(.caption)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(width: 148, alignment: .leading)
                    .padding(.bottom, -1)
                
                HStack {
                    Group {
                        Text(String(format: "%.1f", project.starAverage))
                        + Text(Image(systemName: "star.fill"))
                            .foregroundColor(.yellow)
                    }
                    .padding(.trailing, -7)
                    
                    Text("•")
                        .bold()
                    
                    ProjectArtistNameView(artistsIDs: artistsIDs)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.leading, -5)
                }
                .foregroundColor(.gray)
                .font(.caption)
                .frame(width: 148, alignment: .leading)
                .padding(.bottom, 1)
            }
        }
        .onAppear {
            fetchProject()
        }
    }
    
    func fetchProject() {
        let query = STARSAPI.GetProjectPreviewQuery(projectId: projectID)
        
        Network.shared.apollo.fetch(query: query) { result in
            switch result {
            case .success(let graphQLResult):
                if let fetchedProject = graphQLResult.data?.projects.first {
                    self.project = fetchedProject
                    
                    if let coverURLString = fetchedProject.covers.first?.image,
                       let url = URL(string: coverURLString) {
                        self.imageURL = url
                    }
                    
                    self.artistsIDs = fetchedProject.projectArtists.compactMap { $0.artist.id }
                }
                self.isLoading = false
            case .failure(let error):
                print("Failed to fetch project \(projectID): \(error)")
                self.isLoading = false
            }
        }
    }
}

#Preview {
    ProjectPreview(projectID: "1")
}
