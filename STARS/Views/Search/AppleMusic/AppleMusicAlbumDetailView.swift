//
//  AppleMusicAlbumDetailView.swift
//  STARS
//
//  Created by Marius Gabriel Budai on 25.10.2025.
//

import SwiftUI
import STARSAPI
import SDWebImageSwiftUI

struct AppleMusicAlbumDetailView: View {
    var albumID: String
    
    @State private var album: STARSAPI.GetAppleMusicAlbumDetailQuery.Data.GetAlbumDetail? = nil
    
    // MARK: Sheet/Search State
    @State private var artistsSearchResults: [STARSAPI.SearchForAppleMusicArtistsQuery.Data.SearchAppleMusicArtist] = []
    @State private var artistsKeptForDisplay: [STARSAPI.SearchForAppleMusicArtistsQuery.Data.SearchAppleMusicArtist] = []
    @State private var alertMessage: String? = nil
    
    // Tracks the context of what the user is currently selecting for the sheet
    // Format: (songId, featureIndex) - only used for featured artist resolution
    @State private var sheetSelectionContext: (id: String, featureIndex: Int)? = nil
    
    // MARK: Song Feature Resolution
    // Maps [Song Apple Music ID: [Selected Apple Music Artist ID?]]
    @State private var songFeaturesToResolve: [String: [String?]] = [:]
    @State private var expandedSongID: String? = nil // Tracks which song's dropdown is open
    
    var body: some View {
        VStack {
            if let album = album {
                ScrollView {
                    let url = formattedArtworkUrl(from: album.coverUrl, width: 300, height: 300)
                    
                    WebImage(url: URL(string: url))
                        .resizable()
                        .frame(width: 256, height: 256)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 2)
                    
                    Text(album.name)
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    
                    if let date = stringToDate(album.releaseDate) {
                        let infoText = ([date.formatted(.dateTime.year().month().day())] +
                                        album.genreNames)
                            .joined(separator: " • ")

                        Text(infoText)
                            .padding(.vertical,5)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                    }
                    
                    // MARK: Main Artists Section (Display Only)
                    if !album.isSingle {
                        HStack {
                            Spacer()
                            
                            VStack {
                                Text("Artists")
                                    .font(.title3)
                                
                                Divider()
                                    .foregroundStyle((Color(hex: String("#\(album.bgColor)")) ?? .gray).secondaryTextGray())
                                
                                // Simplified: Just display the main artists
                                ForEach(album.artists, id: \.id) { artist in
                                    Text(artist.name)
                                }
                                .padding(5)
                            }
                            .padding()
                            
                            Spacer()
                        }
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundStyle((Color(hex: String("#\(album.bgColor)")) ?? .gray).prefersWhiteText() ? .white : .black)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color(hex: String("#\(album.bgColor)")) ?? .gray)
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: Song List and Feature Resolution UI
                    ForEach(Array(album.songs.enumerated()), id: \.element.id) { index, song in
                        VStack(alignment: .leading) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(index + 1). \(song.name)")
                                        .bold()
                                    
                                    // Display main song artists
                                    ForEach(song.artists, id: \.id) { songArtist in
                                        Text(songArtist.name)
                                    }
                                }
                                
                                Spacer()
                                
                                // Toggle for feature resolution dropdown
                                Button {
                                    withAnimation {
                                        // Close if already open, or open if closed/different
                                        expandedSongID = expandedSongID == song.id ? nil : song.id
                                        
                                        // Initialize features if expanding for the first time
                                        if expandedSongID == song.id && songFeaturesToResolve[song.id] == nil {
                                            songFeaturesToResolve[song.id] = []
                                        }
                                    }
                                } label: {
                                    Image(systemName: expandedSongID == song.id ? "chevron.up" : "chevron.down")
                                        .padding(.horizontal)
                                }
                            }
                            
                            // MARK: Feature Resolution Dropdown (New)
                            if expandedSongID == song.id {
                                featureResolutionDropdown(song: song)
                            }
                        }
                        
                        if index < album.songs.count - 1 {
                            Divider()
                        }
                    }
                    .padding(.horizontal)
                    
                    // TODO: Add the final "Add Album to STARS" button here, which calls the mutation
                    
                    Spacer()
                }
                .alert(alertMessage ?? "", isPresented: Binding(
                    get: { alertMessage != nil },
                    set: { if !$0 { alertMessage = nil } }
                )) {
                    Button("OK", role: .cancel) { alertMessage = nil }
                }
                // MARK: Artist Selection Sheet
                .sheet(
                    isPresented: Binding(
                        get: { sheetSelectionContext != nil },
                        set: { if !$0 { sheetSelectionContext = nil } }
                    )
                ) {
                    ArtistSelectionSheet(
                        artistsSearchResults: $artistsSearchResults,
                        artistsKeptForDisplay: $artistsKeptForDisplay,
                        sheetSelectionContext: $sheetSelectionContext,
                        songFeaturesToResolve: $songFeaturesToResolve,
                        fetchAppleMusicArtists: fetchAppleMusicArtists // Passed for sheet's internal search
                    )
                }
            }
            
            else {
                ProgressView()
            }
        }
        .onAppear {
            fetchAlbum(id: albumID)
        }
    }
    
    // MARK: Helper Functions
    
    // NEW HELPER: Retrieves the artist's name from the currently available search results.
    func featuredArtistName(for artistID: String?) -> String? {
        guard let id = artistID else { return nil }
        return artistsKeptForDisplay.first(where: { $0.id == id })?.name
    }
    
    @ViewBuilder
    func featureResolutionDropdown(song: STARSAPI.GetAppleMusicAlbumDetailQuery.Data.GetAlbumDetail.Song) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // + / - Buttons for count
            HStack {
                Text("Manual Featured Artists:")
                Spacer()
                
                Button {
                    // Minus button
                    if var features = songFeaturesToResolve[song.id], !features.isEmpty {
                        features.removeLast()
                        songFeaturesToResolve[song.id] = features
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                }
                .disabled(songFeaturesToResolve[song.id]?.isEmpty ?? true)

                Text("\(songFeaturesToResolve[song.id]?.count ?? 0)")

                Button {
                    // Plus button
                    var features = songFeaturesToResolve[song.id] ?? []
                    features.append(nil) // Add an unresolved placeholder
                    songFeaturesToResolve[song.id] = features
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
            .padding(.top, 5)
            
            // Artist Selection Fields
            if let features = songFeaturesToResolve[song.id], !features.isEmpty {
                ForEach(features.indices, id: \.self) { featureIndex in
                    let selectedArtistID = features[featureIndex]
                    let isResolved = selectedArtistID != nil
                    
                    HStack {
                        // FIX: Use the new helper to display the name
                        if let artistName = featuredArtistName(for: selectedArtistID) {
                            Text("Feature \(featureIndex + 1): \(artistName)")
                                .lineLimit(1)
                        } else {
                            Text("Feature \(featureIndex + 1): Unresolved")
                                .italic()
                        }
                        
                        Spacer()
                        
                        Button {
                            // 1. Set context to open sheet for this featured artist slot
                            sheetSelectionContext = (song.id, featureIndex)
                            
                            // 2. SMART PRE-LOADING: If an artist is already selected, search for them
                            if let artistID = selectedArtistID,
                               let artistName = featuredArtistName(for: artistID) {
                                // Search for the selected artist so they are visible on open
                                fetchAppleMusicArtists(term: artistName)
                            } else {
                                // If unresolved, clear results for a clean start
                                artistsSearchResults = []
                            }
                        } label: {
                            Text(isResolved ? "Change" : "Select Artist")
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(isResolved ? Color.green.opacity(0.8) : Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    // ... (rest of the API and utility functions)
    
    func formattedArtworkUrl(from template: String, width: Int = 600, height: Int = 600) -> String {
        return template
            .replacingOccurrences(of: "{w}", with: "\(width)")
            .replacingOccurrences(of: "{h}", with: "\(height)")
    }
    
    func stringToDate(_ dateString: String) -> Foundation.Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: dateString)
    }
    
    func fetchAlbum(id: String) {
        let query = STARSAPI.GetAppleMusicAlbumDetailQuery(albumId: albumID)
        
        Network.shared.apollo.fetch(query: query) { result in
            switch result {
            case .success(let graphQLResult):
                if let fetchedAlbum = graphQLResult.data?.getAlbumDetail {
                    DispatchQueue.main.async {
                        // Initialize features array for all songs with empty arrays
                        for song in fetchedAlbum.songs {
                            self.songFeaturesToResolve[song.id] = []
                        }
                        
                        self.album = fetchedAlbum
                    }
                } else if let errors = graphQLResult.errors {
                    print("GraphQL errors:", errors)
                }
            case .failure(let error):
                print("Error fetching apple music album detail: \(error)")
            }
        }
    }
    
    // Retained for Sheet's internal search function
    func fetchAppleMusicArtists(term: String) {
        let query = STARSAPI.SearchForAppleMusicArtistsQuery(term: term)
        
        Network.shared.apollo.fetch(query: query) { result in
            switch result {
            case .success(let graphQLResult):
                if let fetchedArtists = graphQLResult.data?.searchAppleMusicArtists {
                    DispatchQueue.main.async {
                        self.artistsSearchResults = fetchedArtists
                    }
                } else if let errors = graphQLResult.errors {
                    print("GraphQL errors:", errors)
                }
            case .failure(let error):
                print("Error fetching apple music artists: \(error)")
            }
        }
    }
}

// MARK: - ArtistSelectionSheet

struct ArtistSelectionSheet: View {
    
    @Binding var artistsSearchResults: [STARSAPI.SearchForAppleMusicArtistsQuery.Data.SearchAppleMusicArtist]
    @Binding var artistsKeptForDisplay: [STARSAPI.SearchForAppleMusicArtistsQuery.Data.SearchAppleMusicArtist]
    // Simplified context: (songId, featureIndex)
    @Binding var sheetSelectionContext: (id: String, featureIndex: Int)?
    
    @Binding var songFeaturesToResolve: [String: [String?]]
    
    let fetchAppleMusicArtists: (String) -> Void
    
    @State private var searchText: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    sheetSelectionContext = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("Select Featured Artist")
                    
                    Image("AppleMusicIcon")
                        .resizable()
                        .frame(width: 22, height: 22)
                }
                
                Spacer()
                
                Button {
                    sheetSelectionContext = nil
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            // Search Bar
            TextField("Search Apple Music...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 24) {
                    ForEach(artistsSearchResults, id: \.id) { artist in
                        VStack {
                            if artist.imageUrl.isEmpty {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 128, height: 128)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            else {
                                let url = formattedArtworkUrl(from: artist.imageUrl, width: 300, height: 300)
                                
                                WebImage(url: URL(string: url))
                                    .resizable()
                                    .frame(width: 128, height: 128)
                                    .clipShape(Circle())
                            }
                            
                            Text(artist.name)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 8)
                        .background(
                            Group {
                                if isArtistSelected(artistID: artist.id) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.accentColor.opacity(0.6))
                                } else {
                                    Color.clear
                                }
                            }
                        )
                        .onTapGesture {
                            handleArtistSelection(selectedArtist: artist)
                        }
                    }
                }
                .padding()
            }
        }
        // 🧩 Limit sheet height
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled(true)
        // FIX: Pre-populate search bar if an artist is already selected
        .onAppear {
            guard let context = sheetSelectionContext else { return }
            
            let selectedArtistID = songFeaturesToResolve[context.id]?[context.featureIndex]
            
            if let artistID = selectedArtistID,
               let selectedArtist = artistsSearchResults.first(where: { $0.id == artistID }) {
                
                // Set the search bar text to the name of the selected artist
                searchText = selectedArtist.name
            }
        }
        .task(id: searchText) {
            if searchText.isEmpty {
                artistsSearchResults.removeAll() // Clear results if search is empty
                return
            }
            
            // 1. Debounce: Wait 250ms. If a new key is pressed, this task will be cancelled and a new one started.
            do {
                try await Task.sleep(for: .milliseconds(250))
            } catch {
                return // Task was cancelled (new input received)
            }
            
            // 2. Perform the API call with the debounced text
            fetchAppleMusicArtists(searchText)
        }
    }
    
    // MARK: Sheet Helper Functions
    
    func formattedArtworkUrl(from template: String, width: Int = 600, height: Int = 600) -> String {
        return template
            .replacingOccurrences(of: "{w}", with: "\(width)")
            .replacingOccurrences(of: "{h}", with: "\(height)")
    }
    
    func isArtistSelected(artistID: String) -> Bool {
        guard let context = sheetSelectionContext,
              let features = songFeaturesToResolve[context.id]
        else { return false }
        
        let featureIndex = context.featureIndex
        
        return features.indices.contains(featureIndex) && features[featureIndex] == artistID
    }

    func handleArtistSelection(selectedArtist: STARSAPI.SearchForAppleMusicArtistsQuery.Data.SearchAppleMusicArtist) {
        guard let context = sheetSelectionContext else { return }
        
        let songID = context.id
        let featureIndex = context.featureIndex
        
        guard var features = songFeaturesToResolve[songID] else { return }
        
        let selectedArtistAppleMusicID = selectedArtist.id
        
        if features.indices.contains(featureIndex) {
            for feature in features {
                if let featureNotNil = feature {
                    print(featureNotNil)
                }
                else {
                    print("This one's nil")
                }
            }
            // Toggle selection
            if features[featureIndex] == selectedArtistAppleMusicID {
                features[featureIndex] = nil // Deselect
            } else {
                features[featureIndex] = selectedArtistAppleMusicID // Select
                if !artistsKeptForDisplay.contains(selectedArtist) {
                    artistsKeptForDisplay.append(selectedArtist)
                }
            }
            songFeaturesToResolve[songID] = features
        }
    }
}

#Preview {
    AppleMusicAlbumDetailView(albumID: "1772364192")
    //BRAT: 1739079974
    //Wicked: 1772364192
}
