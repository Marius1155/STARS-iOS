//
//  SearchAppleMusicAlbumsView.swift
//  STARS
//
//  Created by Marius Gabriel Budai on 24.10.2025.
//

import SwiftUI
import STARSAPI

struct SearchAppleMusicAlbumsView: View {
    @Environment(\.colorScheme) var colorScheme

    @State private var albums: [STARSAPI.SearchAppleMusicAlbumsQuery.Data.SearchAppleMusicAlbum] = []
    @State var searchText: String
    
    var body: some View {
        VStack(spacing: 10) {
            if searchText.isEmpty && albums.isEmpty {
                emptyStatePlaceholder
            }
            else if !searchText.isEmpty && albums.isEmpty {
                ContentUnavailableView.search(text: searchText)
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
        .task(id: searchText) {
            if searchText.isEmpty {
                albums.removeAll()
                return
            }
            
            // 1. Debounce: Wait 250ms. If a new key is pressed, this task will be cancelled and a new one started.
            do {
                try await Task.sleep(for: .milliseconds(250))
            } catch {
                return // Task was cancelled (new input received)
            }
            
            // 2. Perform the API call with the debounced text
            fetchAlbums(term: searchText)
        }
        .navigationTitle("Search Albums")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Search Albums")
                    .font(.headline)
                    .foregroundColor(.clear)
            }
        }
    }
    
    @ViewBuilder
        var emptyStatePlaceholder: some View {
            VStack(spacing: 24) {
                Spacer()
                Spacer()
                
                Image("AppleMusicIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                    .shadow(color: colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 8) {
                    Text("Search Apple Music")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                    
                    Text("Find albums to add to the database.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                Spacer()
                Spacer()
            }
        }
    
    func fetchAlbums(term: String) {
        let query = STARSAPI.SearchAppleMusicAlbumsQuery(term: term)
        
        Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
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
        SearchAppleMusicAlbumsView(searchText: "")
    }
}
