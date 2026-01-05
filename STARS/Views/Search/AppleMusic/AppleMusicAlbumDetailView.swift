//
//  AppleMusicAlbumDetailView.swift
//  STARS
//
//  Created by Marius Gabriel Budai on 25.10.2025.
//

import SwiftUI
import STARSAPI
import SDWebImageSwiftUI
import AVFoundation
import Foundation

struct AppleMusicAlbumDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    var albumID: String
    
    @State private var player: AVPlayer?
    @State private var playingSongID: String?
    
    @State private var album: STARSAPI.GetAppleMusicAlbumDetailQuery.Data.GetAlbumDetail? = nil
    @State private var bgColor: Color = .gray
    
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
    @State private var selectedAlternativeVersionIDs: Set<String?> = []
    
    @State private var isAddingProject: Bool = false
    @State private var showSuccessAlert: Bool = false
    
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
                        .padding(.horizontal)
                    
                    // Display the main artists formatted as a single string
                    Text(formatMainArtists(album.artists.map { $0.name }))
                        .font(.title3)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Inside your body ...
                    if let infoText = makeInfoText(for: album) {
                        HStack {
                            Spacer()
                            
                            infoText
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
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .bold()
                                if album.isSingle {
                                    Text("Not available for singles")
                                        .multilineTextAlignment(.leading)
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                } else if selectedAlternativeVersionIDs.isEmpty {
                                    Text("No alternative versions")
                                        .multilineTextAlignment(.leading)
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                } else if selectedAlternativeVersionIDs.contains(nil) {
                                    Text("Make a selection")
                                        .multilineTextAlignment(.leading)
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                } else {
                                    Text("\(selectedAlternativeVersionIDs.count) selected")
                                        .multilineTextAlignment(.leading)
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                            //.foregroundStyle(colorScheme == .dark ? .white : .black)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(album.isSingle)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                    VStack(spacing: 0) {
                        let isMultiDisc = album.songs.contains(where: { $0.discNumber > 1 })
                        
                        // MARK: Song List and Feature Resolution UI
                        ForEach(album.songs, id: \.id) { song in
                            let albumArtistsListIsIdenticalToSongArtistsList = album.artists.map { $0.name } == song.artists.map { $0.name }
                            
                            VStack(alignment: .leading) {
                                if song.trackNumber == 1 && isMultiDisc {
                                    HStack {
                                        Text("Disc \(song.discNumber)")
                                            .fontWeight(.semibold)
                                        
                                        Spacer()
                                    }
                                    .padding(.top)
                                }
                                
                                HStack {
                                    VStack {
                                        if albumArtistsListIsIdenticalToSongArtistsList {
                                            Spacer()
                                        }
                                        
                                        Text("\(song.trackNumber)")
                                            .foregroundStyle(song.isOut ? .gray : Color(uiColor: .systemGray3))
                                        
                                        Spacer()
                                    }
                                    .frame(width: 25)
                                    .padding(.trailing, 5)
                                    
                                    VStack(alignment: .leading) {
                                        Text(song.name)
                                            .foregroundStyle(song.isOut ? (colorScheme == .dark ? .white : .black) : Color(uiColor: .systemGray3))
                                        
                                        if !albumArtistsListIsIdenticalToSongArtistsList {
                                            Text(formatMainArtists(song.artists.map { $0.name }))
                                                .foregroundStyle(song.isOut ? .gray : Color(uiColor: .systemGray3))
                                                .font(.caption)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // Toggle for feature resolution dropdown
                                    Button {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)){
                                            // Close if already open, or open if closed/different
                                            expandedSongID = expandedSongID == song.id ? nil : song.id
                                            
                                            // Initialize features if expanding for the first time
                                            if expandedSongID == song.id && songFeaturesToResolve[song.id] == nil {
                                                self.songFeaturesToResolve[song.id] = []
                                            }
                                        }
                                    } label: {
                                        Image(systemName: expandedSongID == song.id ? "chevron.up" : "chevron.down")
                                        //.foregroundStyle(colorScheme == .dark ? .white : .black)
                                            .padding(.horizontal)
                                    }
                                    .disabled(!song.isOut)
                                }
                                .padding(.vertical, 10)
                                .background(.background)
                                .zIndex(1)
                                
                                // MARK: Feature Resolution Dropdown
                                if expandedSongID == song.id {
                                    featureResolutionDropdown(song: song)
                                        .transition(.move(edge: .top).combined(with: .opacity))
                                        .zIndex(0)
                                        .padding(.top, -5)
                                        .padding(.bottom, 10)
                                }
                            }
                            .clipped()
                            
                            Divider()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, -16)
                    
                    Spacer()
                }
                .alert(alertMessage ?? "", isPresented: Binding(
                    get: { alertMessage != nil },
                    set: { if !$0 { alertMessage = nil } }
                )) {
                    Button("OK", role: .cancel) { alertMessage = nil }
                }
                .alert("Project added successfully!", isPresented: $showSuccessAlert) {
                    Button("OK") {
                        // 3. Return to Home only when OK is pressed
                        dismiss()
                    }
                } message: {
                    Text("The project has been successfully added to the STARS database.")
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
                        player: $player,
                        playingSongID: $playingSongID,
                        playPreview: playPreview,
                        fetchAppleMusicArtists: fetchAppleMusicArtists,
                        fetchArtistTopSongs: fetchArtistTopSongs,
                        bgColor: bgColor
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
                        songsAreBeingFetchedForDeduplication: $songsAreBeingFetchedForDeduplication,
                        bgColor: bgColor
                    )
                }
                // MARK: Alternative Versions Sheet (NEW)
                .sheet(isPresented: $showAlternativeVersionsSheet) {
                    AlternativeVersionsSheet(
                        albumID: album.id,
                        availableProjects: $availableAlternativeVersions,
                        selectedIDs: $selectedAlternativeVersionIDs,
                        isLoading: $isLoadingAlternativeVersions,
                        bgColor: bgColor
                    )
                }
                .tint(bgColor)
                
                Button {
                    if songFeaturesToResolve.values.contains(where: { $0.contains(nil) }) || appleMusicSongsCorrespondentsFromSTARSdb.values.contains(where: { $0 == "" }) || (selectedAlternativeVersionIDs.contains(nil) && !album.isSingle) {
                        alertMessage = "Incomplete information!"
                    }
                    else {
                        isAddingProject = true
                        
                        Task {
                            do {
                                var songsTuples: [(position: Int, discNumber: Int, songId: String?, appleMusicID: String?, title: String?, length: Int?, previewUrl: String?, releaseDate: String?, isOut: Bool?, appleMusicUrl: String?, genres: [String]?, artistsAppleMusicIDs: [String]?)] = []
                                
                                for song in album.songs {
                                    if let songID = appleMusicSongsCorrespondentsFromSTARSdb[song.id] ?? nil {
                                        songsTuples.append((
                                            position: song.trackNumber,
                                            discNumber: song.discNumber,
                                            songId: songID,
                                            appleMusicID: nil,
                                            title: nil,
                                            length: nil,
                                            previewUrl: nil,
                                            releaseDate: nil,
                                            isOut: nil,
                                            appleMusicUrl: nil,
                                            genres: nil,
                                            artistsAppleMusicIDs: nil
                                        ))
                                    }
                                    else {
                                        var artistsIDs: [String] = song.artists.map { $0.id }
                                        
                                        if let features = songFeaturesToResolve[song.id] {
                                            let unwrappedFeatures = features.compactMap { $0 }
                                            artistsIDs.append(contentsOf: unwrappedFeatures)
                                        }
                                        
                                        songsTuples.append((
                                            position: song.trackNumber,
                                            discNumber: song.discNumber,
                                            songId: nil,
                                            appleMusicID: song.id,
                                            title: song.name,
                                            length: song.lengthMs,
                                            previewUrl: song.previewUrl,
                                            releaseDate: song.releaseDate,
                                            isOut: song.isOut,
                                            appleMusicUrl: song.url,
                                            genres: song.genreNames,
                                            artistsAppleMusicIDs: artistsIDs
                                        ))
                                    }
                                }
                                
                                let projectID = try await addProjectToDB(
                                    appleMusicID: album.id,
                                    title: album.name,
                                    isSingle: album.isSingle,
                                    genres: album.genreNames,
                                    numberOfSongs: album.trackCount,
                                    releaseDate: album.releaseDate,
                                    coverUrl: album.coverUrl,
                                    recordLabel: album.recordLabel,
                                    alternativeVersions: Array(selectedAlternativeVersionIDs.compactMap { $0 }),
                                    appleMusicUrl: album.url,
                                    artistsAppleMusicIDs: album.artists.map(\.id),
                                    songsTuplesList: songsTuples
                                )
                                
                                print("Success: \(projectID)")
                                
                                isAddingProject = false
                                showSuccessAlert = true
                            } catch {
                                isAddingProject = false
                                print(error)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        
                        Image(systemName: "plus.app.fill")
                        
                        Text("Add to STARS database")
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
                .padding(.horizontal)
            }
            else {
                ProgressView("Loading project data...")
            }
        }
        .onAppear {
            fetchAlbum(id: albumID)
        }
        .overlay {
            if isAddingProject {
                ZStack {
                    // Dimmed background
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    // Loading Box
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.primary)
                        
                        VStack(spacing: 4) {
                            Text("Adding Project...")
                                .font(.headline)
                            
                            Text("Please don't leave this page")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(24)
                    .background(.regularMaterial) // Glass effect
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 10)
                }
            }
        }
        .disabled(isAddingProject)
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
    
    
    func addProjectToDB(appleMusicID: String, title: String, isSingle: Bool, genres: [String], numberOfSongs: Int, releaseDate: String, coverUrl: String, recordLabel: String, alternativeVersions: [String], appleMusicUrl: String, artistsAppleMusicIDs: [String], songsTuplesList: [(position: Int, discNumber: Int, songId: String?, appleMusicID: String?, title: String?, length: Int?, previewUrl: String?, releaseDate: String?, isOut: Bool?, appleMusicUrl: String?, genres: [String]?, artistsAppleMusicIDs: [String]?)]) async throws -> String {
        
        let songs = songsTuplesList.map { tuple in
            STARSAPI.SongCreateInput(
                position: tuple.position,
                discNumber: tuple.discNumber,
                songId: tuple.songId.map { .some($0) } ?? .null,
                appleMusicId: tuple.appleMusicID.map { .some($0) } ?? .null,
                title: tuple.title.map { .some($0) } ?? .null,
                length: tuple.length.map { .some($0) } ?? .null,
                previewUrl: tuple.previewUrl.map { .some($0) } ?? .null,
                releaseDate: tuple.releaseDate.map { .some($0) } ?? .null,
                isOut: tuple.isOut.map { .some($0) } ?? .null,
                appleMusicUrl: tuple.appleMusicUrl.map { .some($0) } ?? .null,
                genres: tuple.genres.map { .some($0) } ?? .null,
                artistsAppleMusicIds: tuple.artistsAppleMusicIDs.map { .some($0) } ?? .null
            )
        }
        
        let projectData = STARSAPI.ProjectCreateInput(
            appleMusicId: appleMusicID,
            title: title,
            isSingle: isSingle,
            genres: genres,
            numberOfSongs: numberOfSongs,
            releaseDate: releaseDate,
            coverUrl: coverUrl,
            recordLabel: recordLabel,
            alternativeVersions: alternativeVersions,
            appleMusicUrl: appleMusicUrl,
            artistsAppleMusicIds: artistsAppleMusicIDs,
            songs: songs
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            Network.shared.apollo.perform(mutation: STARSAPI.CreateProjectMutation(data: projectData)) { result in
                switch result {
                case .success(let graphQLResult):
                    if let projectID = graphQLResult.data?.createProject.id {
                        continuation.resume(returning: projectID)
                    } else if let errors = graphQLResult.errors {
                        print("GraphQL errors: \(errors)")
                        continuation.resume(throwing: NSError(domain: "GraphQL", code: 400, userInfo: ["errors": errors]))
                    }
                case .failure(let error):
                    print("Network error: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: Helper Views
    
    func makeInfoText(for album: STARSAPI.GetAppleMusicAlbumDetailQuery.Data.GetAlbumDetail) -> Text? {
        // 1. Validate Date
        guard let date = stringToDate(album.releaseDate) else { return nil }
        
        // 2. Prepare Data
        let filteredGenres = album.genreNames.filter { $0 != "Music" }
        let projectType = album.isSingle ? "Single" : (album.trackCount <= 6 ? "EP" : "Album")
        
        // 3. Start with Image + Project Type
        var text = Text(Image(systemName: "opticaldisc.fill")).bold() + Text(" \(projectType)")
        
        // 4. Prepare list of items to append
        let remainingItems = [date.formatted(.dateTime.year().month().day())] + filteredGenres
        
        // 5. Loop and append with bold dots
        for item in remainingItems {
            text = text + Text(" • ").bold() + Text(item)
        }
        
        return text
    }
    
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
                
                // MARK: Play Preview Button
                // We check if the URL exists and is not empty
                HStack(spacing: 10) { // Added spacing in case you keep them side-by-side
                    // MARK: Preview Button
                    if !song.previewUrl.isEmpty {
                        Button {
                            playPreview(url: song.previewUrl, songID: song.id)
                        } label: {
                            HStack {
                                Image(systemName: playingSongID == song.id ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.title3)
                                
                                Text("Preview")
                                    .fontWeight(.semibold)
                                
                                Spacer()
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal)
                            .foregroundStyle(
                                (Color(hex: "#\(album.bgColor)") ?? .gray).prefersWhiteText() ? .white : .black
                            )
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color(hex: String("#\(album.bgColor)")) ?? .gray)
                            }
                        }
                    }
                    
                    // MARK: Deduplication Button
                    Button {
                        self.songToDeduplicate = song
                        self.duplicateSongsResults = []
                        self.fetchExistingSongs(title: song.name) {
                            self.songsAreBeingFetchedForDeduplication = false
                        }
                    } label: {
                        HStack {
                            Image(systemName: "square.stack.3d.down.right.fill")
                                .font(.title3)
                            
                            Text("Deduplicate")
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        // 1. Removed .font(.subheadline) so it matches "Preview" size
                        // 2. Increased padding to 10 to match "Preview" height
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .foregroundStyle(self.appleMusicSongsCorrespondentsFromSTARSdb[song.id] == "" ? (Color.red.opacity(0.8).prefersWhiteText() ? .white : .black) : (Color.green.opacity(0.8).prefersWhiteText() ? .white : .black))
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(self.appleMusicSongsCorrespondentsFromSTARSdb[song.id] == "" ? Color.red.opacity(0.8) : Color.green.opacity(0.8))
                        }
                    }
                }
                
                if song.name.cleaningTitleOfFeatures() != song.name && self.appleMusicSongsCorrespondentsFromSTARSdb[song.id] == nil{
                    // + / - Buttons for count
                    
                    VStack {
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
                                    .font(.title2)
                                    .foregroundStyle((songFeaturesToResolve[song.id]?.count ?? 0) <= 1 ? .gray : (colorScheme == .dark ? .white : .black))
                            }
                            .disabled(songFeaturesToResolve[song.id]?.isEmpty ?? true)
                            
                            Text("\(songFeaturesToResolve[song.id]?.count ?? 0)")
                                .monospacedDigit()
                                .font(.headline)
                                .frame(minWidth: 20)
                            
                            Button {
                                // Plus button
                                var features = songFeaturesToResolve[song.id] ?? []
                                features.append(nil) // Add an unresolved placeholder
                                songFeaturesToResolve[song.id] = features
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                            }
                        }
                        
                        // Artist Selection Fields
                        VStack(alignment: .leading, spacing: 20) {
                            if let features = songFeaturesToResolve[song.id], !features.isEmpty {
                                ForEach(features.indices, id: \.self) { featureIndex in
                                    let selectedArtistID = features[featureIndex]
                                    let isResolved = selectedArtistID != nil
                                    
                                    HStack {
                                        VStack {
                                            Text("\(featureIndex + 1)")
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding(.trailing, 10)
                                        
                                        if let artistName = featuredArtistName(for: selectedArtistID) {
                                            Text(artistName)
                                                .lineLimit(1)
                                        } else {
                                            Text("No artist selected")
                                                .italic()
                                                .foregroundStyle(.secondary)
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
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .onDisappear {
                player?.pause()
                playingSongID = nil
            }
        }
    }

    // MARK: Audio Helper
    private func playPreview(url: String, songID: String) {
        if playingSongID == songID {
            // Tapped the playing song: Pause it
            player?.pause()
            playingSongID = nil
        } else {
            // Tapped a new song: Play it
            guard let audioURL = URL(string: url) else { return }
            
            // Activate audio session so it plays even if the silent switch is on
            try? AVAudioSession.sharedInstance().setCategory(.playback)
            try? AVAudioSession.sharedInstance().setActive(true)
            
            player?.pause()
            player = AVPlayer(url: audioURL)
            player?.play()
            playingSongID = songID
        }
    }
    
    // MARK: API Functions
    
    func formattedArtworkUrl(from template: String, width: Int = 600, height: Int = 600) -> String {
        return template
            .replacingOccurrences(of: "{w}", with: "\(width * 3)")
            .replacingOccurrences(of: "{h}", with: "\(height * 3)")
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
                            if song.isOut {
                                self.appleMusicSongsCorrespondentsFromSTARSdb[song.id] = ""
                            }
                            else {
                                self.appleMusicSongsCorrespondentsFromSTARSdb[song.id] = nil
                            }
                            self.selectedAlternativeVersionIDs.insert(nil)
                        }
                        
                        self.bgColor = (Color(hex: "#\(fetchedAlbum.bgColor)") ?? .gray)
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
        
        Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely) { result in
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
        let query = STARSAPI.SearchExistingSongsQuery(title: title)
        
        Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely) { result in
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
    @Binding var selectedIDs: Set<String?>
    @Binding var isLoading: Bool
    var bgColor: Color
    
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
                Text("Alternative Versions (from the STARS database)")
                    .font(.title3)
                    .multilineTextAlignment(.leading)
                    .bold()
                    .padding()
                
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
                   .padding(.top, 50)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: selectedIDs.isEmpty ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(selectedIDs.isEmpty ? .accentColor : .gray)
                                .font(.title3)
                            
                            Text("No alternative versions")
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
                                            selectedIDs.remove(nil)
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
        .tint(bgColor)
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
    
    @Binding var player: AVPlayer?
    @Binding var playingSongID: String?
    
    let playPreview: (String, String) -> Void
    
    let fetchAppleMusicArtists: (String) -> Void
    // New dependency: fetchArtistTopSongs from parent view
    let fetchArtistTopSongs: (String) async -> [STARSAPI.GetAppleMusicArtistTopSongsQuery.Data.GetAppleMusicArtistTopSong]
    
    var bgColor: Color
    
    @State private var searchText: String = ""
    
    // NEW STATE: Tracks which artist's song list is expanded and stores the fetched songs
    @State private var artistToDisplaySongsFor: String? = nil
    @State private var artistTopSongs: [String: [STARSAPI.GetAppleMusicArtistTopSongsQuery.Data.GetAppleMusicArtistTopSong]] = [:]
    
    var body: some View {
        VStack {
            HStack {
                HStack(spacing: 4) {
                    Text("Select Featured Artist")
                        .font(.title3)
                        .multilineTextAlignment(.leading)
                        .bold()
                        .padding([.leading, .vertical])
                        
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
        .tint(bgColor)
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
                    topSongs: artistTopSongs[artistID],
                    player: $player,
                    playingSongID: $playingSongID,
                    playPreview: playPreview,
                    bgColor: bgColor
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
    
    @Binding var player: AVPlayer?
    @Binding var playingSongID: String?
    
    let playPreview: (String, String) -> Void
    
    var bgColor: Color
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Top 10 Songs for \(artistName)")
                    .font(.title3)
                    .multilineTextAlignment(.leading)
                    .bold()
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            ScrollView {
                if let songs = topSongs {
                    if songs.isEmpty {
                        Text("No top songs available for this artist.")
                            .foregroundStyle(.secondary)
                            .padding(.top, 50)
                    } else {
                        ForEach(songs, id: \.id) { song in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    // 1. System image and bigger font
                                    HStack(spacing: 5) {
                                        Image(systemName: "music.note")
                                            .foregroundStyle(.primary)
                                        Text(song.name)
                                    }
                                    .font(.headline)
                                    .lineLimit(1)
                                    
                                    // 2. Formatted artists on the next line
                                    Text(song.artistsNames)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                .padding(.vertical, 4)
                                
                                Spacer()
                                
                                // 3. Play Button
                                if !song.previewUrl.isEmpty {
                                    Button {
                                        playPreview(song.previewUrl, song.id)
                                    } label: {
                                        Image(systemName: playingSongID == song.id ? "pause.circle.fill" : "play.circle.fill")
                                            .contentTransition(.symbolEffect(.replace)) // Nice transition animation
                                    }
                                    .buttonStyle(.plain) // Prevents the whole row from flashing if in a List
                                }
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
        .tint(bgColor)
        .padding()
        .presentationDetents([.medium, .large])
        // 4. Stop audio when the sheet is dismissed
        .onDisappear {
            player?.pause()
            playingSongID = nil
        }
    }
}

struct SongDeduplicationSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var appleMusicSong: STARSAPI.GetAppleMusicAlbumDetailQuery.Data.GetAlbumDetail.Song?
    @Binding var duplicateSongsResults: [STARSAPI.SearchExistingSongsQuery.Data.Songs.Edge.Node]
    @Binding var appleMusicSongsCorrespondentsFromSTARSdb: [String: String?]
    @Binding var songsAreBeingFetchedForDeduplication: Bool
    
    var bgColor: Color
    
    var body: some View {
        VStack {
            HStack {
                Text("Deduplicate: \(appleMusicSong?.name ?? "Unknown Song")")
                    .font(.title3)
                    .multilineTextAlignment(.leading)
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
            }
            
            Divider()
            
            HStack {
                Text("Select an existing song to use for this album track:")
                    .font(.subheadline)
                
                Spacer()
            }
            
            // List of potential duplicates
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // 1. "Song does not exist" option (Maps to nil/New Song)
                    HStack {
                        Image(systemName: appleMusicSongsCorrespondentsFromSTARSdb[appleMusicSong?.id ?? ""] == nil ? "largecircle.fill.circle" : "circle")
                            .foregroundColor(appleMusicSongsCorrespondentsFromSTARSdb[appleMusicSong?.id ?? ""] == nil ? .accentColor : .gray)
                        Text("Song does not exist in the STARS database (Create New)")
                            .font(.body)
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
                    
                    ForEach($duplicateSongsResults, id: \.id) { $song in
                        let isSelected = appleMusicSongsCorrespondentsFromSTARSdb[appleMusicSong?.id ?? ""] == song.id
                        
                        HStack {
                            Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(isSelected ? .primary : .gray)
                            
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
            
            if duplicateSongsResults.isEmpty && songsAreBeingFetchedForDeduplication {
                VStack {
                    ProgressView("Looking for songs in the STARS database...")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()
                }
            }
            else if duplicateSongsResults.isEmpty && !songsAreBeingFetchedForDeduplication{
                VStack {
                    ContentUnavailableView(
                            "No Songs Found",
                            systemImage: "music.note.list",
                            description: Text("No songs matching the selected song found in the STARS database.")
                        )
                    
                    Spacer()
                }
            }
        }
        .tint(bgColor)
        .padding()
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled(true)
    }
}

#Preview {
    AppleMusicAlbumDetailView(albumID: "1840879306")
    //BRAT: 1739079974
    //Wicked: 1772364192
    //Vroom Vroom - EP: 1083723149
    //Kiss The Beast: 1840879306
    //Brat and it's completely different: 1767862943
    //Back To Basics: 402298887
    //Future Starts Now - Single: 1581933300
}
