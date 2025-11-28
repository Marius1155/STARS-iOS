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
    @State private var artists: [STARSAPI.SearchForAppleMusicArtistsQuery.Data.SearchAppleMusicArtist] = []
    
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
                    
                    if !album.isSingle {
                        HStack {
                            Spacer()
                            
                            VStack {
                                Text("Artists")
                                    .font(.title3)
                                
                                Divider()
                                    .foregroundStyle((Color(hex: String("#\(album.bgColor)")) ?? .gray).secondaryTextGray())
                                
                                ForEach(Array(album.artists.enumerated()), id: \.element.id) { index, artist in
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
                    
                    ForEach(Array(album.songs.enumerated()), id: \.element.id) { index, song in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(index + 1). \(song.name)")
                                    .bold()
                                
                                ForEach(Array(song.artists.enumerated()), id: \.element.id) { songArtistIndex, songArtist in
                                    Text(songArtist.name)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        if index < album.songs.count - 1 {
                            Divider()
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .sheet(
                    isPresented: Binding(
                        get: { selectedArtistIDToAdd != nil },
                        set: { if !$0 { selectedArtistIDToAdd = nil; selectedArtistIndexToAdd = nil } }
                    )
                ) {
                    VStack {
                        HStack {
                            Button {
                                selectedArtistIndexToAdd = nil
                                
                                if let artistID = selectedArtistIDToAdd {
                                    artistsAppleMusicIDToStarsDbID[artistID] = nil
                                }
                                
                                selectedArtistIDToAdd = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text("Choose from Apple Music")
                                
                                Image("AppleMusicIcon")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                            }
                            
                            Spacer()
                            
                            Button {
                                selectedArtistIDToAdd = nil
                                selectedArtistIndexToAdd = nil
                            } label: {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                        
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 24) {
                                ForEach(Array(artists.enumerated()), id: \.element.id) { _, artist in
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
                                            if let artistID = artistsAppleMusicIDToStarsDbID[artist.id],
                                               artistID != nil {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .opacity(0.6)
                                            } else {
                                                Color.clear
                                            }
                                        }
                                    )
                                    .onTapGesture {
                                        if let artistID = selectedArtistIDToAdd,
                                           artistID == artist.id {
                                            artistsAppleMusicIDToStarsDbID[artistID] = nil
                                        }
                                        else {
                                            if let artistID = selectedArtistIDToAdd {
                                                artistsAppleMusicIDToStarsDbID[artistID] = artist.id
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    // 🧩 Limit sheet height
                    .presentationDetents([.medium]) // choose what you allow
                    .presentationDragIndicator(.hidden) // optional drag bar
                    .interactiveDismissDisabled(true) // 🚫 disable swipe down to dismiss
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
    
    func fetchAppleMusicArtists(term: String) {
        let query = STARSAPI.SearchForAppleMusicArtistsQuery(term: term)
        
        Network.shared.apollo.fetch(query: query) { result in
            switch result {
            case .success(let graphQLResult):
                if let fetchedArtists = graphQLResult.data?.searchAppleMusicArtists {
                    DispatchQueue.main.async {
                        self.artists = fetchedArtists
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

#Preview {
    AppleMusicAlbumDetailView(albumID: "1772364192")
    //BRAT: 1739079974
    //Wicked: 1772364192
}











//
//  AppleMusicAlbumDetailView.swift
//  STARS
//
//  Created by Marius Gabriel Budai on 25.10.2025.
//

/*import SwiftUI
import STARSAPI
import SDWebImageSwiftUI

struct AppleMusicAlbumDetailView: View {
    var albumID: String
    
    @State private var album: STARSAPI.GetAppleMusicAlbumDetailQuery.Data.GetAlbumDetail? = nil
    @State private var artistsExistAlready: [Bool?] = []
    @State private var artistsAppleMusicIDToStarsDbID: [String: String?] = [:]
    @State private var alertMessage: String? = nil
    @State private var selectedArtistIDToAdd: String? = nil
    @State private var selectedArtistIndexToAdd: Int? = nil
    @State private var artists: [STARSAPI.SearchForAppleMusicArtistsQuery.Data.SearchAppleMusicArtist] = []
    
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
                    
                    if !album.isSingle {
                        HStack {
                            Spacer()
                            
                            VStack {
                                Text("Artists")
                                    .font(.title3)
                                
                                Divider()
                                    .foregroundStyle((Color(hex: String("#\(album.bgColor)")) ?? .gray).secondaryTextGray())
                                
                                ForEach(Array(album.artists.enumerated()), id: \.element.id) { index, artist in
                                    HStack {
                                        Text(artist.name)
                                        
                                        if let artistExists = artistsExistAlready[index] {
                                            Image(systemName: artistExists || artistsAppleMusicIDToStarsDbID[artist.id] != nil ? "checkmark.circle.fill" : "x.circle.fill")
                                                .foregroundStyle(artistExists || artistsAppleMusicIDToStarsDbID[artist.id] != nil ? .green : .red)
                                                .background {
                                                    Circle()
                                                        .foregroundStyle((Color(hex: String("#\(album.bgColor)")) ?? .gray).prefersWhiteText() ? .white : .black)
                                                }
                                                .onTapGesture {
                                                    if !artistExists {
                                                        alertMessage = "\(artist.name) does not exist in the STARS database and needs to be added."
                                                    }
                                                }
                                            
                                            if !artistExists {
                                                Button {
                                                    artists = []
                                                    fetchAppleMusicArtists(term: artist.name)
                                                    selectedArtistIDToAdd = artist.id
                                                    selectedArtistIndexToAdd = index
                                                } label: {
                                                    Image(systemName: "chevron.right")
                                                }
                                            }
                                        }
                                        
                                    }
                                    .onAppear {
                                        Task {
                                            artistsExistAlready[index] = await checkIfArtistExistsInDatabase(id: artist.id)
                                        }
                                    }
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
                    
                    ForEach(Array(album.songs.enumerated()), id: \.element.id) { index, song in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(index + 1). \(song.name)")
                                    .bold()
                                
                                ForEach(Array(song.artists.enumerated()), id: \.element.id) { songArtistIndex, songArtist in
                                    Text(songArtist.name)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        if index < album.songs.count - 1 {
                            Divider()
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .alert(alertMessage ?? "", isPresented: Binding(
                    get: { alertMessage != nil },
                    set: { if !$0 { alertMessage = nil } }
                )) {
                    Button("OK", role: .cancel) { alertMessage = nil }
                }
                .sheet(
                    isPresented: Binding(
                        get: { selectedArtistIDToAdd != nil },
                        set: { if !$0 { selectedArtistIDToAdd = nil; selectedArtistIndexToAdd = nil } }
                    )
                ) {
                    VStack {
                        HStack {
                            Button {
                                selectedArtistIndexToAdd = nil
                                
                                if let artistID = selectedArtistIDToAdd {
                                    artistsAppleMusicIDToStarsDbID[artistID] = nil
                                }
                                
                                selectedArtistIDToAdd = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text("Choose from Apple Music")
                                    
                                Image("AppleMusicIcon")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                            }
                            
                            Spacer()
                            
                            Button {
                                selectedArtistIDToAdd = nil
                                selectedArtistIndexToAdd = nil
                            } label: {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                        
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 24) {
                                ForEach(Array(artists.enumerated()), id: \.element.id) { _, artist in
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
                                            if let artistID = artistsAppleMusicIDToStarsDbID[artist.id],
                                               artistID != nil {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .opacity(0.6)
                                            } else {
                                                Color.clear
                                            }
                                        }
                                    )
                                    .onTapGesture {
                                        if let artistID = selectedArtistIDToAdd,
                                           artistID == artist.id {
                                            artistsAppleMusicIDToStarsDbID[artistID] = nil
                                        }
                                        else {
                                            if let artistID = selectedArtistIDToAdd {
                                                artistsAppleMusicIDToStarsDbID[artistID] = artist.id
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    // 🧩 Limit sheet height
                    .presentationDetents([.medium]) // choose what you allow
                    .presentationDragIndicator(.hidden) // optional drag bar
                    .interactiveDismissDisabled(true) // 🚫 disable swipe down to dismiss
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
                        self.artistsExistAlready = Array(repeating: nil, count: fetchedAlbum.artists.count)
                        self.artistsAppleMusicIDToStarsDbID = Dictionary(uniqueKeysWithValues: fetchedAlbum.artists.map { ($0.id, nil) })
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
    
    func checkIfArtistExistsInDatabase(id: String) async -> Bool {
        let query = STARSAPI.FindArtistWithGivenAppleMusicIdQuery(id: id)
        
        return await withCheckedContinuation { continuation in
            Network.shared.apollo.fetch(query: query) { result in
                switch result {
                case .success(let graphQLResult):
                    let exists = (graphQLResult.data?.artists.edges.first?.node) != nil
                    continuation.resume(returning: exists)
                case .failure(let error):
                    print("Error fetching artist: \(error)")
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    
}

#Preview {
    AppleMusicAlbumDetailView(albumID: "1772364192")
    //BRAT: 1739079974
    //Wicked: 1772364192
}*/

