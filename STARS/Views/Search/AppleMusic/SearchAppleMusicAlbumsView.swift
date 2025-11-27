//
//  SearchAppleMusicAlbumsView.swift
//  STARS
//
//  Created by Marius Gabriel Budai on 24.10.2025.
//

import SwiftUI
import STARSAPI

struct SearchAppleMusicAlbumsView: View {
    @State private var albums: [STARSAPI.SearchAppleMusicAlbumsQuery.Data.SearchAppleMusicAlbum] = []
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            if searchText.isEmpty && albums.isEmpty {
                VStack {
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("Search Apple Music")
                            .font(.title3)
                        Image("AppleMusicIcon")
                            .resizable()
                            .frame(width: 22, height: 22)
                        Text("for albums")
                            .font(.title3)
                    }
                    
                    Spacer()
                }
            }
            else if !searchText.isEmpty && albums.isEmpty {
                VStack {
                    Spacer()
                    
                    Text("No albums found")
                    
                    Spacer()
                }
            }
            else {
                ScrollView {
                    VStack {
                        ForEach(albums, id: \.id) {album in
                            NavigationLink {
                                AppleMusicAlbumDetailView(albumID: album.id)
                            } label: {
                                ProjectListPreview(id: album.id, title: album.name, releaseDate: album.releaseDate, coverUrl: album.coverUrl, artistsNames: album.artistsNames, trackCount: album.trackCount, isSingle: album.isSingle)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search albums")
        .onChange(of: searchText) { oldValue, newValue in
            guard newValue.count > 1 else {
                albums.removeAll()
                return
            }
            fetchAlbums(term: newValue)
        }
    }
    
    func fetchAlbums(term: String) {
        let query = STARSAPI.SearchAppleMusicAlbumsQuery(term: term)
        
        Network.shared.apollo.fetch(query: query) { result in
            switch result {
            case .success(let graphQLResult):
                if let fetchedAlbums = graphQLResult.data?.searchAppleMusicAlbums {
                    DispatchQueue.main.async {
                        self.albums = fetchedAlbums
                    }
                } else if let errors = graphQLResult.errors {
                    print("GraphQL errors:", errors)
                }
            case .failure(let error):
                print("Error fetching apple music albums: \(error)")
            }
        }
    }
}

#Preview {
    NavigationView {
        SearchAppleMusicAlbumsView()
    }
}
