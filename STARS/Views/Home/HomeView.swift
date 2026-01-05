//
//  FeedView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 08.12.2024.
//

import SwiftUI
import STARSAPI

struct HomeView: View {
     
    @AppStorage("userID") var userID: String = ""
    
    @State private var isReady = false
    @State private var featuredProjects: [(id: String, title: String, starAverage: Double, coverImage: String, primaryColor: String, secondaryColor: String, artists: [(id: String, name: String, position: Int)])] = []
    
    var body: some View {
        ScrollView {
            if !isReady {
                Spacer()
                ProgressView()
                    .frame(width: 100, height: 100)
                Spacer()
            } else {
                VStack(alignment: .leading) {
                    Text("Featured Projects")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                        .padding(.top)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(featuredProjects, id: \.id) { projectData in
                                NavigationLink {
                                    //ProjectDetailView(projectID: projectData.id)
                                    
                                } label: {
                                    ProjectPreview(projectData: projectData)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            fetchFeaturedProjects()
            NotificationCenter.default.post(name: .showTabBar, object: nil)
            DataManager.shared.shouldShowTabBar = true
        }
        .navigationTitle("STARS")
    }
    
    func fetchFeaturedProjects() {
        let query = STARSAPI.GetFeaturedProjectsQuery()
        
        Network.shared.apollo.fetch(query: query) { result in
            switch result {
            case .success(let graphQLResult):
                if let projects = graphQLResult.data?.projects {
                                    featuredProjects = projects.edges.compactMap { edge in
                                        let node = edge.node
                                        let coverNode = node.covers.edges.first?.node
                                        
                                        return (
                                            id: node.id,
                                            title: node.title,
                                            starAverage: node.starAverage,
                                            coverImage: coverNode?.image ?? "",
                                            primaryColor: coverNode?.primaryColor ?? "",
                                            secondaryColor: coverNode?.secondaryColor ?? "",
                                            artists: node.projectArtists.edges.compactMap { artistEdge in
                                                return (
                                                    id: artistEdge.node.artist.id,
                                                    name: artistEdge.node.artist.name,
                                                    position: artistEdge.node.position
                                                )
                                            }
                                        )
                                    }
                    isReady = true
                }
            case .failure(let error):
                print("Failed to fetch featured projects: \(error)")
            }
        }
    }
}

#Preview {
    HomeView()
}
