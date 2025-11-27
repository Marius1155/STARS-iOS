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
}

#Preview {
    AppleMusicAlbumDetailView(albumID: "1772364192")
    //BRAT: 1739079974
    //Wicked: 1772364192
}
