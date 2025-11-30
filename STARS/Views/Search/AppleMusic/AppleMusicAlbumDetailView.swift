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
    @Environment(\.colorScheme) var colorScheme
    
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
    
    // MARK: Song Deduplication State
    @State private var songToDeduplicate: STARSAPI.GetAppleMusicAlbumDetailQuery.Data.GetAlbumDetail.Song? = nil
    @State private var duplicateSongsResults: [STARSAPI.SearchExistingSongsQuery.Data.Songs.Edge.Node] = []
    @State private var appleMusicSongsCorrespondentsFromSTARSdb: [String: String?] = [:]
    
    @State private var songsAreBeingFetchedForDeduplication: Bool = false
    
    // MARK: Alternative Versions State (NEW)
    @State private var showAlternativeVersionsSheet: Bool = false
    @State private var isLoadingAlternativeVersions: Bool = false
    // We store the specific project node type from the query
    @State private var availableAlternativeVersions: [STARSAPI.GetArtistsProjectsQuery.Data.Artists.Edge.Node.ProjectArtists.Edge.Node.Project] = []
    // Store the IDs of the selected projects
    @State private var selectedAlternativeVersionIDs: Set<String> = []

    
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
                        .padding(.top, 10)
                    
                    // Display the main artists formatted as a single string
                    Text(formatMainArtists(album.artists.map { $0.name }))
                        .font(.title3)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center) // Enables multiline centering
                    
                    if let date = stringToDate(album.releaseDate) {
                        let filteredGenres = album.genreNames.filter { $0 != "Music" }
                        
                        let infoText = ([date.formatted(.dateTime.year().month().day())] +
                                        filteredGenres)
                            .joined(separator: " • ")

                        HStack {
                            Spacer()
                            
                            Text(infoText)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                            
                            Spacer()
                        }
                        .padding()
                        .foregroundStyle(
                            (Color(hex: "#\(album.bgColor)") ?? .gray).prefersWhiteText() ? .white : .black
                        )
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color(hex: String("#\(album.bgColor)")) ?? .gray)
                        }
                        .padding(.horizontal)
                        .padding(.top, -3)
                    }
                    
                    // MARK: Alternative Versions Button (NEW)
                    Button {
                        // Trigger fetch if we haven't already or if we want to refresh
                        fetchAlternativeVersions()
                        showAlternativeVersionsSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.stack.badge.plus")
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                            
                            VStack(alignment: .leading) {
                                Text("Alternative Versions")
                                    .bold()
                                if !selectedAlternativeVersionIDs.isEmpty {
                                    Text("\(selectedAlternativeVersionIDs.count) selected")
                                        .font(.caption)
                                        .opacity(0.8)
                                } else {
                                    Text("None selected")
                                        .font(.caption)
                                        .opacity(0.8)
                                }
                            }
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.primary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                    // MARK: Song List and Feature Resolution UI
                    ForEach(Array(album.songs.enumerated()), id: \.element.id) { index, song in
                        VStack(alignment: .leading) {
                            HStack {
                                VStack {
                                    Text("\(index + 1)")
                                        .foregroundStyle(.gray)
                                    
                                    Spacer()
                                }
                                .frame(width: 25)
                                .padding(.trailing, 5)
                                
                                VStack(alignment: .leading) {
                                    Text(song.name)
                                    
                                    Text(formatMainArtists(song.artists.map { $0.name }))
                                        .foregroundStyle(.gray)
                                        .font(.caption)
                                }
                                
                                Spacer()
                                
                                // Toggle for feature resolution dropdown
                                Button {
                                    withAnimation {
                                        // Close if already open, or open if closed/different
                                        expandedSongID = expandedSongID == song.id ? nil : song.id
                                        
                                        // Initialize features if expanding for the first time
                                        if expandedSongID == song.id && songFeaturesToResolve[song.id] == nil {
                                            self.songFeaturesToResolve[song.id] = []
                                        }
                                    }
                                } label: {
                                    Image(systemName: expandedSongID == song.id ? "chevron.up" : "chevron.down")
                                        .padding(.horizontal)
                                }
                            }
                            
                            // MARK: Feature Resolution Dropdown
                            if expandedSongID == song.id {
                                featureResolutionDropdown(song: song)
                            }
                        }
                        
                        if index < album.songs.count - 1 {
                            Divider()
                        }
                    }
                    .padding(.horizontal)
                    
                    Button {
                        
                    } label: {
                        HStack {
                            Spacer()
                            
                            Image(systemName: "plus.app.fill")
                            
                            Text("Add project to STARS database")
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        .padding()
                        .foregroundStyle(
                            (Color(hex: "#\(album.bgColor)") ?? .gray).prefersWhiteText() ? .white : .black
                        )
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color(hex: String("#\(album.bgColor)")) ?? .gray)
                        }
                    }
                    .padding()
                    
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
                        fetchAppleMusicArtists: fetchAppleMusicArtists,
                        fetchArtistTopSongs: fetchArtistTopSongs
                    )
                }
                // MARK: Song Deduplication Sheet
                .sheet(
                    isPresented: Binding(
                        get: { songToDeduplicate != nil },
                        set: { if !$0 { songToDeduplicate = nil } }
                    )
                ) {
                    SongDeduplicationSheet(
                        appleMusicSong: $songToDeduplicate,
                        duplicateSongsResults: $duplicateSongsResults,
                        appleMusicSongsCorrespondentsFromSTARSdb: $appleMusicSongsCorrespondentsFromSTARSdb,
                        songsAreBeingFetchedForDeduplication: $songsAreBeingFetchedForDeduplication
                    )
                }
                // MARK: Alternative Versions Sheet (NEW)
                .sheet(isPresented: $showAlternativeVersionsSheet) {
                    AlternativeVersionsSheet(
                        albumID: album.id,
                        availableProjects: $availableAlternativeVersions,
                        selectedIDs: $selectedAlternativeVersionIDs,
                        isLoading: $isLoadingAlternativeVersions
                    )
                }
                .tint(Color(hex: String("#\(album.bgColor)")) ?? .gray)
            }
            else {
                ProgressView()
            }
        }
        .onAppear {
            fetchAlbum(id: albumID)
        }
        .navigationTitle(album?.name ?? "Unknown")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(album?.name ?? "")
                    .font(.headline)
                    .foregroundColor(.clear)
            }
        }
    }
    
    // MARK: Helper Views
    
    // NEW HELPER: Retrieves the artist's name from the currently available search results.
    func featuredArtistName(for artistID: String?) -> String? {
        guard let id = artistID else { return nil }
        // Ensure this logic continues to use artistsKeptForDisplay
        return artistsKeptForDisplay.first(where: { $0.id == id })?.name
    }
    
    func formatMainArtists(_ names: [String]) -> String {
        guard !names.isEmpty else { return "" }
        
        // Case 1: Single artist
        if names.count == 1 {
            return names.first!
        }
        
        // Case 2: Two artists (A & B)
        if names.count == 2 {
            return names.joined(separator: " & ")
        }
        
        // Case 3: Three or more (A, B & C)
        let last = names.last!
        let rest = names.dropLast().joined(separator: ", ")
        
        return "\(rest) & \(last)"
    }
    
    @ViewBuilder
    func featureResolutionDropdown(song: STARSAPI.GetAppleMusicAlbumDetailQuery.Data.GetAlbumDetail.Song) -> some View {
        if let album = self.album {
            VStack(alignment: .leading, spacing: 10) {
                
                // MARK: Deduplication Button
                Button {
                    // Set the song to initiate the sheet
                    self.songToDeduplicate = song
                    // Clear and initiate the search immediately upon opening
                    self.duplicateSongsResults = []
                    self.fetchExistingSongs(title: song.name) {
                        self.songsAreBeingFetchedForDeduplication = false
                    }
                } label: {
                    HStack {
                        Image(systemName: "square.stack.3d.down.right.fill")
                        Text("Check for Existing Song (Deduplicate)")
                    }
                    .font(.subheadline)
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(self.appleMusicSongsCorrespondentsFromSTARSdb[song.id] == "" ? (Color.red.opacity(0.8).prefersWhiteText() ? .white : .black) : (Color.green.opacity(0.8).prefersWhiteText() ? .white : .black))
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(self.appleMusicSongsCorrespondentsFromSTARSdb[song.id] == "" ? Color.red.opacity(0.8) : Color.green.opacity(0.8))
                    }
                }
                
                if song.name.cleaningTitleOfFeatures() != song.name && self.appleMusicSongsCorrespondentsFromSTARSdb[song.id] == nil{
                    // + / - Buttons for count
                    HStack {
                        Text("Add ONLY the featured artists manually (the main artists are taken care of automatically):")
                            .bold()
                        
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
                                if let artistName = featuredArtistName(for: selectedArtistID) {
                                    Text("Feature \(featureIndex + 1): \(artistName)")
                                        .lineLimit(1)
                                } else {
                                    Text("Feature \(featureIndex + 1): ") + Text("Empty").italic()
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
                                        .foregroundStyle(features[featureIndex] == nil ? (Color.red.opacity(0.8).prefersWhiteText() ? .white : .black) : (Color.green.opacity(0.8).prefersWhiteText() ? .white : .black))
                                        .background {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundStyle(features[featureIndex] == nil ? Color.red.opacity(0.8) : Color.green.opacity(0.8))
                                        }
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    // MARK: API Functions
    
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
                            self.appleMusicSongsCorrespondentsFromSTARSdb[song.id] = ""
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
    
    // NEW: Fetch Alternative Versions (Projects) based on the first artist
    func fetchAlternativeVersions() {
        guard let firstArtist = album?.artists.first else {
            print("No artist available to fetch projects for")
            return
        }
        
        self.isLoadingAlternativeVersions = true
        
        let query = STARSAPI.GetArtistsProjectsQuery(artistAppleMusicId: firstArtist.id)
        
        Network.shared.apollo.fetch(query: query) { result in
            DispatchQueue.main.async {
                self.isLoadingAlternativeVersions = false
            }
            
            switch result {
            case .success(let graphQLResult):
                DispatchQueue.main.async {
                    // Navigate the graph: Artists -> Edges -> Node -> ProjectArtists -> Edges -> Node -> Project
                    // We extract all projects from all edges found
                    if let artistNode = graphQLResult.data?.artists.edges.first?.node {
                        let fetchedProjects = artistNode.projectArtists.edges.compactMap { $0.node.project }
                        self.availableAlternativeVersions = fetchedProjects
                    }
                }
            case .failure(let error):
                print("Error fetching alternative versions: \(error)")
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
    
    // Function to search local DB for existing songs
    func fetchExistingSongs(title: String, completion: @escaping () -> Void) {
        self.songsAreBeingFetchedForDeduplication = true
        
        // 1. Get the required Apple Music IDs from the target song (songToDeduplicate)
        guard let targetSong = self.songToDeduplicate else {
            print("No song to deduplicate selected.")
            self.songsAreBeingFetchedForDeduplication = false
            completion()
            return
        }
        
        // Create a Set of the required IDs for O(1) lookups
        // properties: songToDeduplicate.artists[].id is the Apple Music ID
        let requiredAppleMusicIDs = Set(targetSong.artists.map { $0.id })
        
        // Note: You can keep cleaningTitleOfFeatures() if you want to normalize the *title search*,
        // but the artist matching below will be strict ID-based.
        let query = STARSAPI.SearchExistingSongsQuery(title: title.cleaningTitleOfFeatures())
        
        Network.shared.apollo.fetch(query: query) { result in
            switch result {
            case .success(let graphQLResult):
                DispatchQueue.main.async {
                    // 2. Get all candidate songs from the query
                    let allFetchedSongs = graphQLResult.data?.songs.edges.compactMap { $0.node } ?? []
                    
                    // 3. Filter: Keep a song ONLY if it contains ALL artist IDs from the target song
                    self.duplicateSongsResults = allFetchedSongs.filter { fetchedSong in
                        
                        // Extract Apple Music IDs from the fetched DB song's artists
                        // Path: songArtists -> edges -> node -> artist -> appleMusicId
                        let fetchedArtistIDs = fetchedSong.songArtists.edges.compactMap { edge in
                            edge.node.artist.appleMusicId
                        }
                        
                        let fetchedIDsSet = Set(fetchedArtistIDs)
                        
                        // Check if the required Apple Music IDs are a subset of the fetched song's artist IDs
                        // (The DB song can have *more* artists, but must include the ones from Apple Music)
                        return requiredAppleMusicIDs.isSubset(of: fetchedIDsSet)
                    }
                    
                    completion()
                }
            case .failure(let error):
                print("Error fetching existing songs: \(error)")
                DispatchQueue.main.async {
                    self.duplicateSongsResults = []
                    completion()
                }
            }
        }
    }
    
    // Function to fetch top songs for an artist
    func fetchArtistTopSongs(artistID: String) async -> [STARSAPI.GetAppleMusicArtistTopSongsQuery.Data.GetAppleMusicArtistTopSong] {
        let query = STARSAPI.GetAppleMusicArtistTopSongsQuery(artistId: artistID)
        
        return await withCheckedContinuation { continuation in
            Network.shared.apollo.fetch(query: query) { result in
                switch result {
                case .success(let graphQLResult):
                    let songs = graphQLResult.data?.getAppleMusicArtistTopSongs ?? []
                    continuation.resume(returning: songs)
                case .failure(let error):
                    print("Error fetching artist top songs: \(error)")
                    continuation.resume(returning: [])
                }
            }
        }
    }
}

// MARK: - Alternative Versions Sheet (NEW)

struct AlternativeVersionsSheet: View {
    @Environment(\.dismiss) var dismiss
    
    // The list of projects fetched from the query
    var albumID: String
    @Binding var availableProjects: [STARSAPI.GetArtistsProjectsQuery.Data.Artists.Edge.Node.ProjectArtists.Edge.Node.Project]
    // The set of IDs selected by the user
    @Binding var selectedIDs: Set<String>
    @Binding var isLoading: Bool
    
    // MARK: Search State
    @State private var searchText: String = ""
    
    // Computed property to filter projects
    var filteredProjects: [STARSAPI.GetArtistsProjectsQuery.Data.Artists.Edge.Node.ProjectArtists.Edge.Node.Project] {
        if searchText.isEmpty {
            return availableProjects.filter { $0.appleMusicId != albumID}
        } else {
            return availableProjects.filter { $0.title.localizedCaseInsensitiveContains(searchText) && $0.appleMusicId != albumID}
        }
    }
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Button {
                    // Cancel/Close
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.clear) // Hidden but keeps spacing
                }
                .padding()
                
                Spacer()
                
                Text("Alternative Versions (from the STARS database)")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    // Done/Save
                    dismiss()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            // MARK: Search Bar
            TextField("Search projects...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .padding(.bottom, 5)
            
            Divider()
            
            if isLoading {
                Spacer()
                ProgressView("Fetching projects...")
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // Option: No Alternative Versions
                        // We always show this option at the top so the user can easily clear selections
                        HStack {
                            Image(systemName: selectedIDs.isEmpty ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(selectedIDs.isEmpty ? .accentColor : .gray)
                                .font(.title3)
                            
                            Text("No Alternative Versions")
                                .font(.body)
                                .padding(.leading, 8)
                            
                            Spacer()
                        }
                        .padding()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                selectedIDs.removeAll()
                            }
                        }
                        
                        Divider()
                        
                        // List of filtered projects
                        if filteredProjects.isEmpty && !searchText.isEmpty {
                            Text("No projects found matching \"\(searchText)\"")
                                .foregroundColor(.secondary)
                                .padding(.top, 20)
                        } else {
                            ForEach(filteredProjects, id: \.id) { project in
                                HStack {
                                    Image(systemName: selectedIDs.contains(project.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedIDs.contains(project.id) ? .accentColor : .gray)
                                        .font(.title3)
                                    
                                    // Cover Image
                                    if let coverNode = project.covers.edges.first?.node {
                                        WebImage(url: URL(string: coverNode.image))
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(10)
                                            .padding(.horizontal, 8)
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(10)
                                            .padding(.horizontal, 8)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text(project.title)
                                            .font(.headline)
                                            .lineLimit(1)
                                        
                                        if let date = stringToDate(project.releaseDate) {
                                            Text(date.formatted(.dateTime.year()))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation {
                                        if selectedIDs.contains(project.id) {
                                            selectedIDs.remove(project.id)
                                        } else {
                                            selectedIDs.insert(project.id)
                                        }
                                    }
                                }
                                
                                Divider()
                            }
                        }
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .interactiveDismissDisabled()
    }
    
    func stringToDate(_ dateString: String) -> Foundation.Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}

// MARK: - ArtistSelectionSheet (Existing)

struct ArtistSelectionSheet: View {
    
    @Binding var artistsSearchResults: [STARSAPI.SearchForAppleMusicArtistsQuery.Data.SearchAppleMusicArtist]
    @Binding var artistsKeptForDisplay: [STARSAPI.SearchForAppleMusicArtistsQuery.Data.SearchAppleMusicArtist]
    // Simplified context: (songId, featureIndex)
    @Binding var sheetSelectionContext: (id: String, featureIndex: Int)?
    
    @Binding var songFeaturesToResolve: [String: [String?]]
    
    let fetchAppleMusicArtists: (String) -> Void
    // New dependency: fetchArtistTopSongs from parent view
    let fetchArtistTopSongs: (String) async -> [STARSAPI.GetAppleMusicArtistTopSongsQuery.Data.GetAppleMusicArtistTopSong]
    
    @State private var searchText: String = ""
    
    // NEW STATE: Tracks which artist's song list is expanded and stores the fetched songs
    @State private var artistToDisplaySongsFor: String? = nil
    @State private var artistTopSongs: [String: [STARSAPI.GetAppleMusicArtistTopSongsQuery.Data.GetAppleMusicArtistTopSong]] = [:]
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.clear)
                }
                .padding()
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("Select Featured Artist")
                        .font(.title3)
                        .bold()
                        
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
            
            // Search Bar (with search-as-you-type logic in .task below)
            TextField("Search Apple Music...", text: $searchText)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 24) {
                    
                    // NEW: Iterate through results and allow expansion
                    ForEach(artistsSearchResults, id: \.id) { artist in
                        VStack(alignment: .leading) {
                            HStack(alignment: .top) {
                                Spacer()
                                
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
                                    
                                    HStack {
                                        Text(artist.name)
                                            .font(.headline)
                                            .multilineTextAlignment(.center)
                                        
                                        Button {
                                            // Set state to trigger modal and initiate fetch
                                            artistToDisplaySongsFor = artist.id
                                            if artistTopSongs[artist.id] == nil {
                                                artistTopSongs[artist.id] = [] // Set empty array to show ProgressView
                                                Task {
                                                    let songs = await fetchArtistTopSongs(artist.id)
                                                    artistTopSongs[artist.id] = songs
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "info.circle") // New icon
                                                .font(.title3)
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                                
                                Spacer()
                            }
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding()
            }
        }
        // 🧩 Fixed height and drag indicator for a cleaner modal
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled(true)
        .onAppear {
            // Pre-fill the search bar based on current selection
            guard let context = sheetSelectionContext else { return }
            
            let selectedArtistID = songFeaturesToResolve[context.id]?[context.featureIndex]
            
            if let artistID = selectedArtistID,
               let selectedArtist = artistsSearchResults.first(where: { $0.id == artistID }) {
                
                searchText = selectedArtist.name
            }
        }
        // MARK: Debounce Logic using .task(id:)
        .task(id: searchText) {
            // Only perform search if the text has at least 2 characters and is not just the pre-loaded name
            guard searchText.count > 2 else {
                if searchText.isEmpty {
                    artistsSearchResults = [] // Clear results if search is empty
                }
                return
            }
            
            // 1. Debounce: Wait 500ms. If a new key is pressed, this task will be cancelled and a new one started.
            do {
                try await Task.sleep(for: .milliseconds(500))
            } catch {
                return // Task was cancelled (new input received)
            }
            
            // 2. Perform the API call with the debounced text
            fetchAppleMusicArtists(searchText)
        }
        // MARK: Top Songs Detail Sheet (Modal triggered by 'info.circle' button)
        .sheet(
            isPresented: Binding(
                get: { artistToDisplaySongsFor != nil },
                set: { if !$0 { artistToDisplaySongsFor = nil } }
            )
        ) {
            if let artistID = artistToDisplaySongsFor,
               let artist = artistsSearchResults.first(where: { $0.id == artistID }) {
                
                TopSongsDetailSheet(
                    artistID: artistID,
                    artistName: artist.name,
                    topSongs: artistTopSongs[artistID]
                )
            }
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
            // Toggle selection
            if features[featureIndex] == selectedArtistAppleMusicID {
                features[featureIndex] = nil // Deselect
            } else {
                features[featureIndex] = selectedArtistAppleMusicID// Select
                if !artistsKeptForDisplay.contains(selectedArtist) {
                    artistsKeptForDisplay.append(selectedArtist)
                }
            }
            songFeaturesToResolve[songID] = features
        }
    }
}

// MARK: - TopSongsDetailSheet (New Helper View for Verification)

struct TopSongsDetailSheet: View {
    let artistID: String
    let artistName: String
    let topSongs: [STARSAPI.GetAppleMusicArtistTopSongsQuery.Data.GetAppleMusicArtistTopSong]?
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Top 10 Songs for \(artistName)")
                    .font(.title3)
                    .bold()
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding()
            }

            Divider()

            ScrollView {
                if let songs = topSongs {
                    if songs.isEmpty {
                        Text("No top songs available for this artist.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(songs, id: \.id) { song in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    // 1. System image and bigger font
                                    HStack(spacing: 5) {
                                        Image(systemName: "music.note")
                                            .foregroundColor(.primary) // Set color explicitly if needed
                                        Text(song.name)
                                    }
                                    .font(.headline) // Apply headline font to both icon and text
                                    .lineLimit(1)
                                    
                                    // 2. Formatted artists on the next line
                                    Text(formatArtists(song.artists))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                .padding(.vertical, 4)
                                
                                Spacer()
                            }
                            Divider()
                        }
                    }
                } else {
                    ProgressView("Loading songs...")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .presentationDetents([.medium, .large]) // Allow expansion for long lists
    }
    
    // Utility to format the artists array: A, B & C
    private func formatArtists(_ artists: [STARSAPI.GetAppleMusicArtistTopSongsQuery.Data.GetAppleMusicArtistTopSong.Artist]) -> String {
        let names = artists.map { $0.name }
        
        guard !names.isEmpty else { return "Unknown Artist(s)" }
        
        if names.count <= 2 {
            return names.joined(separator: " & ")
        } else {
            let last = names.last!
            let others = names.dropLast().joined(separator: ", ")
            return "\(others) & \(last)"
        }
    }
}

struct SongDeduplicationSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var appleMusicSong: STARSAPI.GetAppleMusicAlbumDetailQuery.Data.GetAlbumDetail.Song?
    @Binding var duplicateSongsResults: [STARSAPI.SearchExistingSongsQuery.Data.Songs.Edge.Node]
    @Binding var appleMusicSongsCorrespondentsFromSTARSdb: [String: String?]
    @Binding var songsAreBeingFetchedForDeduplication: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Button {
                    
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.clear)
                }
                .padding()
                
                Spacer()
                
                Text("Deduplicate: \(appleMusicSong?.name ?? "Unknown Song")")
                    .font(.title3)
                    .bold()
                
                Spacer()
                
                Button {
                    // Confirm selection and close
                    dismiss()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            Divider()
            
            Text("Select an existing song to use for this album track:")
                .font(.subheadline)
            
            // List of potential duplicates
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // 1. "Song does not exist" option (Maps to nil/New Song)
                    HStack {
                        Image(systemName: appleMusicSongsCorrespondentsFromSTARSdb[appleMusicSong?.id ?? ""] == nil ? "largecircle.fill.circle" : "circle")
                            .foregroundColor(appleMusicSongsCorrespondentsFromSTARSdb[appleMusicSong?.id ?? ""] == nil ? .accentColor : .gray)
                        Text("Song does not exist in STARS (Create New)")
                            .font(.headline)
                            .padding(.vertical, 8)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let appleMusicSong = appleMusicSong {
                            self.appleMusicSongsCorrespondentsFromSTARSdb[appleMusicSong.id] = nil
                        }
                    }
                    Divider()
                    
                    // 2. List of existing songs from DB
                    if duplicateSongsResults.isEmpty && songsAreBeingFetchedForDeduplication {
                        ProgressView("Looking for songs in the STARS database...")
                            .padding()
                    }
                    else if duplicateSongsResults.isEmpty && !songsAreBeingFetchedForDeduplication{
                        Text("No songs matching the selected song found in the STARS database.")
                            .padding()
                    }
                    else {
                        ForEach($duplicateSongsResults, id: \.id) { $song in
                            let isSelected = appleMusicSongsCorrespondentsFromSTARSdb[appleMusicSong?.id ?? ""] == song.id
                            
                            HStack {
                                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(isSelected ? .accentColor : .gray)
                                
                                VStack(alignment: .leading) {
                                    Text(song.title)
                                        .font(.headline)
                                        .lineLimit(1)
                                    
                                    // Display artists in the database
                                    let artistNames = song.songArtists.edges.map { $0.node.artist.name }
                                    Text("Artists: \(artistNames.joined(separator: ", "))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                .padding(.vertical, 8)
                                
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if let appleMusicSong = appleMusicSong {
                                    self.appleMusicSongsCorrespondentsFromSTARSdb[appleMusicSong.id] = song.id
                                }
                            }
                            Divider()
                        }
                    }
                }
            }
        }
        .padding()
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled(true)
    }
}

import Foundation

extension String {
    /**
     Cleans a song title by removing featured artist markers (feat., ft., featuring)
     and all text that follows them from a song title.
     
     This implementation covers all major variations of the feature marker:
     - Keywords: feat, feat., ft, ft., featuring (case-insensitive)
     - Enclosure: Parentheses (), Square Brackets [], and Curly Braces {}
     
     Example: "Title {Ft. Artist}" -> "Title"
     */
    func cleaningTitleOfFeatures() -> String {
        // IMPROVED Pattern: Matches optional space, optional enclosure ([(|{]), (keywords), optional enclosure ([)|}]), and everything that follows.
        let pattern = "\\s*[\\(\\[\\{]?(feat\\.?|ft\\.?|featuring)[\\)\\]\\}]?.*$"

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            
            // 1. Replace the matched pattern with an empty string
            let range = NSRange(location: 0, length: self.utf16.count)
            let clean = regex.stringByReplacingMatches(
                in: self,
                options: [],
                range: range,
                withTemplate: ""
            )
            
            // 2. Clean up trailing whitespace and punctuation left behind
            var finalTitle = clean.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Remove any trailing punctuation (e.g., a comma or period right before the feature began)
            if let lastChar = finalTitle.last, ",.:;".contains(lastChar) {
                finalTitle.removeLast()
            }
            
            return finalTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } catch {
            // Should not happen with a static pattern
            print("Regex compilation failed: \(error)")
            return self.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}

#Preview {
    AppleMusicAlbumDetailView(albumID: "1083723149")
    //BRAT: 1739079974
    //Wicked: 1772364192
    //Vroom Vroom - EP: 1083723149
}
