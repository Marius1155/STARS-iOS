//
//  YouTubePerformanceVideoDetailView.swift
//  STARS
//
//  Created by STARS App Developer on 07.12.2025.
//

import SwiftUI
import STARSAPI
import SDWebImageSwiftUI
import Foundation
import AVFoundation

// 1. Define the types to match your Django Backend Choices
enum EventType: String, CaseIterable, Identifiable {
    case makeASelection = "MAKE_A_SELECTION"
    case awardShow = "AWARD_SHOW"
    case tour = "TOUR"
    case festival = "FESTIVAL"
    case tvAppearance = "TV_SHOW"
    case liveSession = "LIVE_SESSION"
    case residency = "RESIDENCY"
    case other = "OTHER"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .makeASelection: return "Choose The Event Type"
        case .awardShow: return "Award Show"
        case .tour: return "Tour"
        case .festival: return "Festival"
        case .tvAppearance: return "TV Show"
        case .liveSession: return "Live Session"
        case .residency: return "Residency"
        case .other: return "Other"
        }
    }
}

struct YouTubePerformanceVideoDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    // --- Inputs ---
    let youtubeVideoId: String
    let youtubeVideoTitle: String
    let youtubeVideoThumbnailUrl: String
    let youtubeVideoChannelName: String
    let youtubeVideoPublishedAt: String
    let youtubeVideoLengthMs: Int
    let youtubeVideoViewCount: Int
    let youtubeVideoUrl: String
    let youtubeVideoPrimaryColor: String
    
    // --- State: Songs ---
    @State private var songSlots: [STARSAPI.AdvancedSongSearchQuery.Data.Songs.Edge.Node?] = [nil]
    @State private var activeSlotIndex: Int? = nil
    
    // --- State: Event Selection/Creation ---
    // 1. Existing Selection
    @State private var selectedEvent: STARSAPI.SearchEventsQuery.Data.Events.Edge.Node?
    
    // 2. Creation Mode
    @State private var isCreatingEvent: Bool = false
    @State private var newEventName: String = ""
    @State private var newEventDate: Foundation.Date = Foundation.Date()
    @State private var newEventLocation: String = ""
    @State private var isOneTimeEvent: Bool = true
    @State private var newEventType: EventType = .makeASelection // New State for Event Type
    
    // 3. Series Logic (For Creation Mode)
    @State private var selectedSeries: STARSAPI.SearchEventSeriesQuery.Data.EventSeries.Edge.Node?
    @State private var newSeriesName: String = "" // Empty string means no new series being created
    @State private var isCreatingNewSeries: Bool = false
    @State private var newSeriesType: EventType = .makeASelection // New State for Series Type
    
    // --- Sheets ---
    @State private var showSongSearchSheet: Bool = false
    @State private var showEventSearchSheet: Bool = false
    @State private var showSeriesSearchSheet: Bool = false
    
    // --- UI/Submission ---
    @State private var new: String = ""
    @State private var isSubmitting: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var alertMessage: String? = nil
    @State private var showInfoAlert: Bool = false
    @FocusState private var isFocusedOnEventTitle: Bool
    @FocusState private var isFocusedOnEventLocation: Bool
    @FocusState private var isFocusedOnSeriesTitle: Bool
    
    // Artists
    @State private var artists: [String: [String?]] = ["0": [nil]]
    @State private var artistsSearchResults: [STARSAPI.SearchForAppleMusicArtistsQuery.Data.SearchAppleMusicArtist] = []
    @State private var artistsKeptForDisplay: [STARSAPI.SearchForAppleMusicArtistsQuery.Data.SearchAppleMusicArtist] = []
    @State private var sheetSelectionContext: (id: String, featureIndex: Int)? = nil
    
    // Song Preview
    @State private var player: AVPlayer?
    @State private var playingSongID: String?
    
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
                    
                    
                    let validArtistNames = (artists["0"] ?? []).compactMap { getArtistName(for: $0) }
                    let validSongTitles = songSlots.compactMap { $0?.title }
                    let hasValidEvent = (selectedEvent != nil) || (isCreatingEvent && !newEventName.isEmpty)

                    if validArtistNames.isEmpty || validSongTitles.isEmpty || !hasValidEvent {
                        Text("Missing information!")
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .padding(.top, 10)
                    } else {
                        Text(formatPerformanceString(
                            artistNames: validArtistNames,
                            songTitles: validSongTitles,
                            eventName: isCreatingEvent ? newEventName : selectedEvent!.name
                        ))
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    
                    // Removed Picker("Performance Type"...) here
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
                
                // MARK: - Event Section
                eventSelection
                
                // MARK: - Artist Selection Section
                artistsSelection
                                
                // MARK: - Song Selection Section
                songsSelection
            }
            
            // MARK: - Add Button
            if !isFocusedOnEventTitle && !isFocusedOnEventLocation && !isFocusedOnSeriesTitle {
                Button {
                    submitPerformanceVideo()
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
        }
        .onDisappear {
            player?.pause()
            playingSongID = nil
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
                songFeaturesToResolve: $artists,
                player: $player,
                playingSongID: $playingSongID,
                playPreview: playPreview,
                fetchAppleMusicArtists: fetchAppleMusicArtists,
                fetchArtistTopSongs: fetchArtistTopSongs,
                bgColor: (Color(hex: String("#\(youtubeVideoPrimaryColor)")) ?? .gray)
            )
        }
        .sheet(isPresented: $showEventSearchSheet) {
            EventSearchSheet(
                selectedExistingEvent: $selectedEvent,
                showInfoAlert: $showInfoAlert,
                onCreateNew: { name in
                    // Trigger creation UI in main view
                    isCreatingEvent = true
                    selectedEvent = nil
                    newEventName = name
                }
            )
        }
        .sheet(isPresented: $showSeriesSearchSheet) {
            EventSeriesSearchSheet(
                selectedSeries: $selectedSeries,
                onCreateNew: { name in
                    // Trigger series textfield in main view
                    isCreatingNewSeries = true
                    selectedSeries = nil
                    newSeriesName = name
                }
            )
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
                            Text("Adding Performance ...")
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
        }
        // MARK: - Alerts
        .alert(alertMessage ?? "Error", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) { alertMessage = nil }
        }
        .alert("Performance Added!", isPresented: $showSuccessAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("The performance has been successfully added to the STARS database.")
        }
        .alert("For Your Information", isPresented: $showInfoAlert) {
            Button("OK") { showInfoAlert = false}
        } message: {
            Text("An event can either be a one-time event (ex: Live Aid 1985) or part of a series, usually of periodically recurring events (ex: Event Series: The Grammys; Event: The 2025 Grammys)")
        }
    }
    
    var eventSelection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Event where the performance took place:").font(.headline)
            
            // 1. Main Trigger Button
            Button {
                showEventSearchSheet = true
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        if isCreatingEvent {
                            Text("Creating New Event...").fontWeight(.semibold).foregroundStyle(colorScheme == .dark ? .white : .black)
                        } else if let event = selectedEvent {
                            Text(event.name).fontWeight(.semibold).foregroundStyle(colorScheme == .dark ? .white : .black)
                            Text(event.date).font(.caption).foregroundStyle(.gray)
                        } else {
                            Text("Select or Create Event").foregroundStyle(.gray).italic()
                        }
                    }
                    Spacer()
                    if isCreatingEvent || selectedEvent != nil {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                            .onTapGesture {
                                // Clear all event data
                                isCreatingEvent = false
                                selectedEvent = nil
                                resetCreationForm()
                            }
                    } else {
                        Image(systemName: "chevron.right").foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(10)
            }
            
            // 2. "More UI" - Creation Form (Appears in Main View)
            if isCreatingEvent {
                VStack(alignment: .leading, spacing: 15) {
                    
                    // A. Name & Location
                    TextField("Event Name", text: $newEventName)
                        .textFieldStyle(.roundedBorder)
                        .focused($isFocusedOnEventTitle)
                    
                    TextField("Location", text: $newEventLocation)
                        .textFieldStyle(.roundedBorder)
                        .focused($isFocusedOnEventLocation)
                    
                    // B. Date
                    DatePicker("Date", selection: $newEventDate, displayedComponents: .date)
                    
                    Divider()
                    
                    if isOneTimeEvent {
                        Picker("Event Type", selection: $newEventType) {
                            ForEach(EventType.allCases) { type in
                                Text(type.title).tag(type)
                            }
                        }
                        .tint(colorScheme == .dark ? .white : .black)
                    }
                    
                    // C. One Time Toggle
                    Toggle("One-time Event", isOn: $isOneTimeEvent)
                    
                    
                    // D. Series Logic (If not one time)
                    if !isOneTimeEvent {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Event Series").font(.subheadline).foregroundStyle(.secondary)
                            
                            // Series Selection Button
                            Button {
                                showSeriesSearchSheet = true
                            } label: {
                                HStack {
                                    if isCreatingNewSeries {
                                        Text("New Series:").font(.caption).bold().foregroundStyle(.green)
                                        Text(newSeriesName.isEmpty ? "Enter name below" : newSeriesName)
                                    } else if let series = selectedSeries {
                                        Text("Series:").font(.caption).foregroundStyle(.secondary)
                                        Text(series.name).fontWeight(.semibold)
                                    } else {
                                        Text("Select Series")
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.down").font(.caption)
                                }
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                            }
                            .buttonStyle(.plain)
                            
                            // E. "Textfield beneath" for New Series Name
                            if isCreatingNewSeries {
                                TextField("New Series Name", text: $newSeriesName)
                                    .textFieldStyle(.roundedBorder)
                                    .overlay(
                                        HStack {
                                            Spacer()
                                            Button {
                                                // Cancel new series creation
                                                isCreatingNewSeries = false
                                                newSeriesName = ""
                                                newSeriesType = .makeASelection
                                            } label: {
                                                Image(systemName: "xmark.circle.fill").foregroundStyle(.gray)
                                            }
                                            .padding(.trailing, 8)
                                        }
                                    )
                                    .focused($isFocusedOnSeriesTitle)
                                
                                // --- CHANGED: If creating new series, show Series Type Picker ---
                                Picker("Series Type", selection: $newSeriesType) {
                                    ForEach(EventType.allCases) { type in
                                        Text(type.title).tag(type)
                                    }
                                }
                                .tint(colorScheme == .dark ? .white : .black)
                            }
                        }
                        .padding(.leading, 10)
                        .padding(.top, 5)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(12)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
    
    var artistsSelection: some View {
        VStack {
            HStack {
                Text("Artists performing:")
                    .bold()
                
                Spacer()
                
                Button {
                    // Minus button
                    if var ar = artists["0"], !ar.isEmpty {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            ar.removeLast()
                            artists["0"] = ar
                        }
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle((artists["0"]?.count ?? 0) <= 1 ? .gray : (colorScheme == .dark ? .white : .black))
                }
                .disabled((artists["0"]?.count ?? 0 ) <= 1)
                
                Text("\(artists["0"]?.count ?? 0)")
                    .monospacedDigit()
                    .font(.headline)
                    .frame(minWidth: 20)
                
                Button {
                    if var ar = artists["0"] {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            ar.append(nil)
                            artists["0"] = ar
                        }
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
            }
            
            VStack(alignment: .leading, spacing: 20) {
                if let ar = artists["0"] {
                    ForEach(ar.indices, id: \.self) { artistIndex in
                        let selectedArtistID = ar[artistIndex]
                        let isResolved = selectedArtistID != nil
                        
                        HStack {
                            VStack {
                                Text("\(artistIndex + 1)")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.trailing, 10)
                            
                            if let artistName = getArtistName(for: selectedArtistID) {
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
                                sheetSelectionContext = ("0", artistIndex)
                                
                                // 2. SMART PRE-LOADING: If an artist is already selected, search for them
                                if let artistID = selectedArtistID,
                                   let artistName = getArtistName(for: artistID) {
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
                                    .foregroundStyle(!isResolved ? (Color.red.opacity(0.8).prefersWhiteText() ? .white : .black) : (Color.green.opacity(0.8).prefersWhiteText() ? .white : .black))
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(!isResolved ? Color.red.opacity(0.8) : Color.green.opacity(0.8))
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
        .padding(.horizontal)
    }
    
    var songsSelection: some View {
        VStack(alignment: .leading) {
            
            HStack {
                Text("Songs performed:")
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
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
            }
            
            VStack(alignment: .leading, spacing: 20) {
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
    
    // MARK: - Helpers
    
    func formatPerformanceString(artistNames: [String], songTitles: [String], eventName: String) -> String {
        
        func joinWithAmpersand(_ items: [String]) -> String {
            if items.isEmpty { return "" }
            if items.count == 1 { return items[0] }
            
            let allButLast = items.dropLast().joined(separator: ", ")
            let last = items.last!
            
            return "\(allButLast) & \(last)"
        }
        
        let artistsStr = joinWithAmpersand(artistNames)
        let songsStr = joinWithAmpersand(songTitles)
        
        return "\(artistsStr) performing \(songsStr) (\(eventName))"
    }
    
    func resetCreationForm() {
        newEventName = ""
        newEventDate = Date()
        newEventLocation = ""
        isOneTimeEvent = true
        selectedSeries = nil
        newSeriesName = ""
        isCreatingNewSeries = false
        newEventType = .makeASelection
        newSeriesType = .makeASelection
    }
    
    func getArtistName(for artistID: String?) -> String? {
        guard let id = artistID else { return nil }
        // Ensure this logic continues to use artistsKeptForDisplay
        return artistsKeptForDisplay.first(where: { $0.id == id })?.name
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
    
    func submitPerformanceVideo() {
        guard isCreatingEvent || selectedEvent != nil else {
            alertMessage = "Please select or create an event!"
            return
        }
        
        if isCreatingEvent {
            
            if newEventName.isEmpty {
                
                alertMessage = "Event name can't be blank!"
                
                return
                
            }
            
            // ONE-TIME EVENT Validation
            
            if isOneTimeEvent {
                if newEventType == .makeASelection {
                    alertMessage = "Please select the type for this one-time event!"
                    
                    return
                }
                
            } else {
                if selectedSeries == nil && !isCreatingNewSeries {
                    alertMessage = "Please select a series for the event, or make it a one-time event!"
                    
                    return
                }
                
                if isCreatingNewSeries {
                    if newSeriesName.isEmpty {
                        alertMessage = "Series name can't be blank!"
                        
                        return
                    }
                    
                    if newSeriesType == .makeASelection {
                        alertMessage = "Please select the type for the new series!"
                        
                        return
                    }
                }
            }
        }
        
        guard let artistsList = artists["0"], !artistsList.contains(nil) else {
            alertMessage = "Please don't leave any of the artist positions empty!"
            return
        }
        
        guard !songSlots.isEmpty, !songSlots.contains(where: { $0 == nil }) else {
            alertMessage = "Please ensure all song slots are filled!"
            return
        }
        
        isSubmitting = true
        let songsIds = songSlots.compactMap { $0?.id }
        
        // Data Preparation
        var eventId: String? = nil
        var eventName: String? = nil
        var eventDate: String? = nil
        var eventLocation: String? = nil
        var seriesId: String? = nil
        var seriesName: String? = nil
        
        // 1. Calculate which type to send to the backend (if any)
        var typeToSubmit: String? = nil
        
        if isCreatingEvent {
            eventName = newEventName
            // Format Date
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            eventDate = formatter.string(from: newEventDate)
            eventLocation = newEventLocation
            
            if isOneTimeEvent {
                // Case 2c: New One-Time Event -> Send newEventType
                typeToSubmit = newEventType.rawValue
            } else {
                // Series Logic
                if isCreatingNewSeries {
                    seriesName = newSeriesName
                    // Case 2b: New Series -> Send newSeriesType
                    typeToSubmit = newSeriesType.rawValue
                } else if let s = selectedSeries {
                    seriesId = s.id
                    // Case 2a: Existing Series -> Backend handles type (we send nil)
                }
            }
        } else if let existing = selectedEvent {
            eventId = existing.id
            // Case 1: Existing Event -> Backend handles type (we send nil)
        }
        
        var artistsIdsToPassOn: [String] = []
        
        for artist in artists["0"] ?? [] {
            if let artist = artist {
                artistsIdsToPassOn.append(artist)
            }
        }
        
        let title = formatPerformanceString(
            artistNames: (artists["0"] ?? []).compactMap { getArtistName(for: $0) },
            songTitles: songSlots.compactMap { $0?.title },
            eventName: isCreatingEvent ? newEventName : selectedEvent!.name
        )
        
        let pvData = STARSAPI.PerformanceVideoInput(
            youtubeId: youtubeVideoId,
            title: title,
            thumbnailUrl: youtubeVideoThumbnailUrl,
            channelName: youtubeVideoChannelName,
            publishedAt: youtubeVideoPublishedAt,
            lengthMs: youtubeVideoLengthMs,
            youtubeUrl: youtubeVideoUrl,
            artistsAppleMusicIds: artistsIdsToPassOn,
            songsIds: songsIds,
            eventId: eventId.map { .some($0) } ?? .null,
            eventName: eventName.map { .some($0) } ?? .null,
            eventDate: eventDate.map { .some($0) } ?? .null,
            eventType: typeToSubmit.map { .some($0) } ?? .null,
            eventLocation: eventLocation.map { .some($0) } ?? .null,
            eventSeriesId: seriesId.map { .some($0) } ?? .null,
            eventSeriesName: seriesName.map { .some($0) } ?? .null
        )
        
        Network.shared.apollo.perform(mutation: STARSAPI.AddPerformanceVideoMutation(data: pvData)) { result in
            DispatchQueue.main.async {
                self.isSubmitting = false
                switch result {
                case .success(let graphQLResult):
                    if graphQLResult.data?.addPerformanceVideo.id != nil {
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

// 1. Helper Struct to pass data back to the main view
struct NewEventData: Equatable {
    var name: String
    var date: Foundation.Date
    var location: String
    var isOneTime: Bool
    var selectedSeriesId: String?
    var newSeriesName: String?
}

// MARK: - Event Search Sheet (Search Only)
struct EventSearchSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    // OUTPUTS
    @Binding var selectedExistingEvent: STARSAPI.SearchEventsQuery.Data.Events.Edge.Node?
    @Binding var showInfoAlert: Bool
    // Callback to tell parent we want to create new, passing the name
    var onCreateNew: (String) -> Void
    
    @State private var searchText: String = ""
    @State private var searchResults: [STARSAPI.SearchEventsQuery.Data.Events.Edge.Node] = []
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Header
            HStack {
                HStack(spacing: 6) {
                    Text("Select Event")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    
                    Image(systemName: "calendar")
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
            
            // MARK: - Search Bar
            TextField("Search events...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .submitLabel(.search)
                .padding(.bottom, 10)
            
            // MARK: - Results List
            ScrollView {
                LazyVStack(spacing: 0) {
                    
                    // "Create New" Option
                    if !searchText.isEmpty {
                        Button {
                            onCreateNew(searchText)
                            selectedExistingEvent = nil
                            showInfoAlert = true
                            dismiss()
                        } label: {
                            VStack(spacing: 0) {
                                HStack {
                                    HStack(spacing: 5) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundStyle(.green)
                                        Text("Create new event: \"\(searchText)\"")
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                    }
                                    .padding(.vertical, 8)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .contentShape(Rectangle())
                                
                                Divider()
                                    .padding(.leading)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Search Results
                    ForEach(searchResults, id: \.id) { event in
                        Button {
                            selectedExistingEvent = event
                            dismiss()
                        } label: {
                            VStack(spacing: 0) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        // Name
                                        Text(event.name)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                        
                                        // Date & Location
                                        Text("\(event.date) • \(event.location)")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                    .padding(.vertical, 8)
                                    
                                    Spacer()
                                    
                                    // Series Tag (Optional)
                                    if let s = event.series {
                                         Text(s.name)
                                            .font(.caption2)
                                            .padding(4)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(4)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    // Selected Checkmark
                                    if selectedExistingEvent?.id == event.id {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                            .padding(.leading, 8)
                                    }
                                }
                                .padding(.horizontal)
                                .contentShape(Rectangle())
                                
                                Divider()
                                    .padding(.leading)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .task(id: searchText) {
            guard searchText.count > 1 else { return }
            await performSearch()
        }
    }
    
    func performSearch() async {
        await withCheckedContinuation { continuation in
            let query = STARSAPI.SearchEventsQuery(term: searchText)
            Network.shared.apollo.fetch(query: query) { result in
                if let data = try? result.get().data {
                    DispatchQueue.main.async { self.searchResults = data.events.edges.compactMap { $0.node } }
                }
                continuation.resume()
            }
        }
    }
}

// MARK: - Event Series Search Sheet (Search Only)
struct EventSeriesSearchSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    // OUTPUTS
    @Binding var selectedSeries: STARSAPI.SearchEventSeriesQuery.Data.EventSeries.Edge.Node?
    // Callback to tell parent we want to create new
    var onCreateNew: (String) -> Void
    
    @State private var searchText: String = ""
    @State private var searchResults: [STARSAPI.SearchEventSeriesQuery.Data.EventSeries.Edge.Node] = []
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Header
            HStack {
                HStack(spacing: 6) {
                    Text("Select Series")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    
                    Image(systemName: "list.star")
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
            
            // MARK: - Search Bar
            TextField("Search series...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .submitLabel(.search)
                .padding(.bottom, 10)
            
            // MARK: - Results List
            ScrollView {
                LazyVStack(spacing: 0) {
                    
                    // "Create New" Option
                    if !searchText.isEmpty {
                        Button {
                            onCreateNew(searchText)
                            selectedSeries = nil
                            dismiss()
                        } label: {
                            VStack(spacing: 0) {
                                HStack {
                                    HStack(spacing: 5) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundStyle(.green)
                                        Text("Create new series: \"\(searchText)\"")
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                    }
                                    .padding(.vertical, 8)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .contentShape(Rectangle())
                                
                                Divider()
                                    .padding(.leading)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Search Results
                    ForEach(searchResults, id: \.id) { series in
                        Button {
                            selectedSeries = series
                            dismiss()
                        } label: {
                            VStack(spacing: 0) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(series.name)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                    }
                                    .padding(.vertical, 8)
                                    
                                    Spacer()
                                    
                                    if selectedSeries?.id == series.id {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                }
                                .padding(.horizontal)
                                .contentShape(Rectangle())
                                
                                Divider()
                                    .padding(.leading)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .task(id: searchText) {
            guard searchText.count > 1 else { return }
            await performSearch()
        }
    }
    
    func performSearch() async {
        await withCheckedContinuation { continuation in
            Network.shared.apollo.fetch(query: STARSAPI.SearchEventSeriesQuery(term: searchText)) { result in
                if let data = try? result.get().data {
                    DispatchQueue.main.async { self.searchResults = data.eventSeries.edges.compactMap { $0.node } }
                }
                continuation.resume()
            }
        }
    }
}

#Preview {
    YouTubePerformanceVideoDetailView(youtubeVideoId: "VJPhmau5Vgk", youtubeVideoTitle: "Sabrina Carpenter - Espresso / Please Please Please (Live From The 67th Grammy Awards / 2025)", youtubeVideoThumbnailUrl: "https://i.ytimg.com/vi/VJPhmau5Vgk/maxresdefault.jpg", youtubeVideoChannelName: "SabrinaCarpenterVEVO", youtubeVideoPublishedAt: "2025-02-18T20:25:00Z", youtubeVideoLengthMs: 296000, youtubeVideoViewCount: 5569471, youtubeVideoUrl: "https://www.youtube.com/watch?v=VJPhmau5Vgk", youtubeVideoPrimaryColor: "373b45")
}
