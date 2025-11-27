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
    @State private var featuredProjectsIDs: [String] = []
    
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
                            ForEach(featuredProjectsIDs, id: \.self) { projectID in
                                NavigationLink {
                                    ProjectDetailView(projectID: projectID)
                                    
                                } label: {
                                    ProjectPreview(projectID: projectID)
                                        .foregroundColor(.primary)
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
                    // Use IDs directly as Int
                    featuredProjectsIDs = projects.edges.compactMap { $0.node.id }
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
