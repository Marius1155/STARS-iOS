//
//  YouTubeMusicVideoDetailView.swift
//  STARS
//
//  Created by STARS App Developer on 07.12.2025.
//

import SwiftUI
import STARSAPI
import SDWebImageSwiftUI
import Foundation

struct YouTubeMusicVideoDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    // Data passed from the previous Search View (YouTube Result)
    
    let youtubeVideoId: String
    let youtubeVideoTitle: String
    let youtubeVideoThumbnailUrl: String
    let youtubeVideoChannelName: String
    let youtubeVideoPublishedAt: String
    let youtubeVideoLengthMs: Int
    let youtubeVideoViewCount: Int
    let youtubeVideoUrl: String
    let youtubeVideoPrimaryColor: String
    
    // We store selected songs. Nil means an empty slot.
    @State private var songSlots: [STARSAPI.AdvancedSongSearchQuery.Data.Songs.Edge.Node?] = [nil] // Start with 1 empty slot
    
    // Sheet State
    @State private var showSongSearchSheet: Bool = false
    @State private var activeSlotIndex: Int? = nil
    
    // Submission State
    @State private var isSubmitting: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var alertMessage: String? = nil
    
    @State private var newTitle: String = ""

    var body: some View {
        VStack {
            ScrollView {
                
                // MARK: - Header (Video Info)
                VStack {
                    WebImage(url: URL(string: youtubeVideoThumbnailUrl))
                        .resizable()
                        .indicator(.activity)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 300, height: 169) // 16:9 aspect ratio
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 5)
                    
                    if songSlots.count <= 1 {
                        Text(songSlots[0]?.title ?? "Missing information!")
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .italic(songSlots[0] == nil)
                            .foregroundStyle(songSlots[0] == nil ? .secondary : .primary)
                    }
                    else {
                        TextField("Music Video Title", text: $newTitle)
                            .textFieldStyle(.roundedBorder)
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 10)
                    }
                    
                    Button {
                        newTitle = youtubeVideoTitle
                    } label: {
                        Label("Reset title", systemImage: "arrow.uturn.backward")
                            .font(.title3)
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 1)
                    }
                    .disabled(songSlots.count <= 1)
                }
                
                if let releaseDate = stringToDate(youtubeVideoPublishedAt) {
                    HStack {
                        Spacer()
                        
                        (Text("\(youtubeVideoViewCount.abbreviatedCount) views") + Text(" • ").bold() + Text("\(releaseDate.formatted(.dateTime.year().month().day()))"))
                        
                        Spacer()
                    }
                    .padding()
                    .foregroundStyle(
                        (Color(hex: "#\(youtubeVideoPrimaryColor)") ?? .gray).prefersWhiteText() ? .white : .black
                    )
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color(hex: String("#\(youtubeVideoPrimaryColor)")) ?? .gray)
                    }
                    .padding(.horizontal)
                }
                
                // MARK: - Song Selection Section
                VStack(alignment: .leading, spacing: 20) {
                    
                    HStack {
                        Text("Songs in this video")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button {
                            if !songSlots.isEmpty {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    _ = songSlots.removeLast()
                                }
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(songSlots.count <= 1 ? .gray : (colorScheme == .dark ? .white : .black))
                        }
                        .disabled(songSlots.count <= 1)
                        
                        Text("\(songSlots.count)")
                            .monospacedDigit()
                            .font(.headline)
                            .frame(minWidth: 20)
                        
                        // Plus Button
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                songSlots.append(nil)
                            }
                        } label: { 
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                    
                    VStack (alignment: .leading, spacing: 20) {
                        ForEach(Array(songSlots.enumerated()), id: \.offset) { index, song in
                            let isSelected = (song != nil)
                            let actualIndex = index + 1
                            
                            HStack {
                                VStack{
                                    Text("\(actualIndex)")
                                        .foregroundStyle(.secondary)
                                    
                                    if isSelected {
                                        //Spacer()
                                    }
                                }
                                .padding(.trailing, 10)
                                
                                if let song = song {
                                    VStack(alignment: .leading) {
                                        Text(song.title)
                                            .lineLimit(1)
                                        
                                        let artistNames = song.songArtists.edges.compactMap { $0.node.artist.name }.joined(separator: ", ")
                                        Text(artistNames)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                } else {
                                    Text("No song selected")
                                        .italic()
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                let buttonBaseColor = isSelected ? Color.green.opacity(0.8) : Color.red.opacity(0.8)
                                let buttonText = isSelected ? "Change" : "Select Song"
                                
                                Button {
                                    activeSlotIndex = index
                                    showSongSearchSheet = true
                                } label : {
                                    Text(buttonText)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 10)
                                        .foregroundStyle(buttonBaseColor.prefersWhiteText() ? .white : .black)
                                        .background {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundStyle(buttonBaseColor)
                                        }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            
            Button {
                submitMusicVideo()
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
                    (Color(hex: "#\(youtubeVideoPrimaryColor)") ?? .gray).prefersWhiteText() ? .white : .black
                )
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color(hex: String("#\(youtubeVideoPrimaryColor)")) ?? .gray)
                }
            }
            .padding(.horizontal)
        }
        .overlay {
            if isSubmitting {
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
                            Text("Adding Music Video...")
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
        .disabled(isSubmitting)
        .onAppear {
            newTitle = youtubeVideoTitle
        }
        .tint(Color(hex: String("#\(youtubeVideoPrimaryColor)")) ?? .gray)
        .navigationTitle(youtubeVideoTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(youtubeVideoTitle)
                    .font(.headline)
                    .foregroundColor(.clear)
            }
        }
        .sheet(isPresented: $showSongSearchSheet) {
            SongSearchSheet(
                selectedSong: Binding(
                    get: {
                        if let index = activeSlotIndex, index < songSlots.count {
                            return songSlots[index]
                        }
                        return nil
                    },
                    set: { newValue in
                        if let index = activeSlotIndex, index < songSlots.count {
                            songSlots[index] = newValue
                        }
                    }
                )
            )
            .hideTabBar()
        }
        // MARK: - Alerts
        .alert(alertMessage ?? "Error", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) { alertMessage = nil }
        }
        .alert("Music Video Added!", isPresented: $showSuccessAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("The music video has been successfully added to the STARS database.")
        }
    }
    
    // MARK: - API Logic
    
    func submitMusicVideo() {
        guard !songSlots.isEmpty, !songSlots.contains(where: { $0 == nil }) else {
            alertMessage = "Please ensure all song slots are filled."
            return
        }
        
        guard !(newTitle.isEmpty && songSlots.count > 1) else {
            alertMessage = "Make sure the title is not blank!"
            return
        }
        
        isSubmitting = true
        
        let songsIds = songSlots.compactMap { $0?.id }
        let title = (songSlots.count <= 1 && songSlots[0] != nil) ? songSlots[0]?.title ?? "Unknown" : newTitle
        
        let mvData = STARSAPI.MusicVideoInput(
            youtubeId: youtubeVideoId,
            title: title,
            thumbnailUrl: youtubeVideoThumbnailUrl,
            channelName: youtubeVideoChannelName,
            publishedAt: youtubeVideoPublishedAt,
            lengthMs: youtubeVideoLengthMs,
            youtubeUrl: youtubeVideoUrl,
            songsIds: songsIds
        )
        
        Network.shared.apollo.perform(mutation: STARSAPI.AddMusicVideoMutation(data: mvData)) { result in
            DispatchQueue.main.async {
                self.isSubmitting = false
                
                switch result {
                case .success(let graphQLResult):
                    if graphQLResult.data?.addMusicVideo.id != nil {
                        self.showSuccessAlert = true
                    } else if let errors = graphQLResult.errors {
                        self.alertMessage = "GraphQL Error: \(errors.map { $0.message ?? "unknown" }.joined(separator: ", "))"
                    }
                case .failure(let error):
                    self.alertMessage = "Network Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func stringToDate(_ dateString: String) -> Foundation.Date? {
        // 1. Try ISO8601 formatter first (Best for API responses)
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: dateString) {
            return date
        }
        
        // 2. Fallback for other common formats (e.g., "yyyy-MM-dd")
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // Essential for fixed formats
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        return nil
    }
}

struct SongSearchSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    // Binding to return the selected song to the parent
    @Binding var selectedSong: STARSAPI.AdvancedSongSearchQuery.Data.Songs.Edge.Node?
    
    @State private var searchText: String = ""
    @State private var searchResults: [STARSAPI.AdvancedSongSearchQuery.Data.Songs.Edge.Node] = []
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Header (ArtistSelectionSheet Style)
            HStack {
                HStack(spacing: 6) {
                    Text("Select Song")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    
                    Image(systemName: "music.note")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            
            // MARK: - Search Bar (ArtistSelectionSheet Style)
            TextField("Search STARS database...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .submitLabel(.search)
                .padding(.bottom, 10)
            
            // MARK: - Results List (TopSongsDetailSheet Style)
            ScrollView {
                if searchResults.isEmpty && !searchText.isEmpty {
                     ContentUnavailableView.search(text: searchText)
                        .padding(.top, 50)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(searchResults, id: \.id) { song in
                            Button {
                                selectedSong = song
                                dismiss()
                            } label: {
                                VStack(spacing: 0) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            // 1. System image and bigger font
                                            HStack(spacing: 5) {
                                                Image(systemName: "music.note")
                                                    .foregroundStyle(.primary)
                                                
                                                Text(song.title)
                                                    .font(.headline)
                                                    .foregroundStyle(.primary)
                                                    .lineLimit(1)
                                            }
                                            
                                            // 2. Formatted artists on the next line
                                            let artistNames = song.songArtists.edges.map { $0.node.artist.name }.joined(separator: ", ")
                                            Text(artistNames)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                        }
                                        .padding(.vertical, 8)
                                        
                                        Spacer()
                                        
                                        // Optional: Checkmark if this specific song is the one currently selected
                                        if selectedSong?.id == song.id {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.blue)
                                        }
                                    }
                                    .padding(.horizontal)
                                    .contentShape(Rectangle()) // Makes the whole row area tappable
                                    
                                    Divider()
                                        .padding(.leading)
                                }
                            }
                            .buttonStyle(.plain) // Standardizes button appearance in lists
                        }
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        
        // MARK: - Search Logic (Debounced)
        .task(id: searchText) {
            guard searchText.count > 1 else {
                if searchText.isEmpty {
                    searchResults = []
                }
                return
            }
            
            await performSearch()
        }
    }
    
    // MARK: - API Call
    func performSearch() async {
        await withCheckedContinuation { continuation in
            let query = STARSAPI.AdvancedSongSearchQuery(term: searchText)
            
            Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely) { result in
                switch result {
                case .success(let graphQLResult):
                    let songs = graphQLResult.data?.songs.edges.compactMap { $0.node } ?? []
                    DispatchQueue.main.async {
                        self.searchResults = songs
                    }
                    continuation.resume()
                    
                case .failure(let error):
                    print("Error searching songs: \(error)")
                    continuation.resume()
                }
            }
        }
    }
}

#Preview {
    YouTubeMusicVideoDetailView(youtubeVideoId: "TZCE6PfaUWA", youtubeVideoTitle: "Slayyyter - CRANK (Official Video)", youtubeVideoThumbnailUrl: "https://i.ytimg.com/vi/TZCE6PfaUWA/maxresdefault.jpg", youtubeVideoChannelName: "SlayyyterVEVO", youtubeVideoPublishedAt: "2025-10-24T04:00:06Z", youtubeVideoLengthMs: 187000, youtubeVideoViewCount: 479544, youtubeVideoUrl: "https://www.youtube.com/watch?v=TZCE6PfaUWA", youtubeVideoPrimaryColor: "443020")
}
