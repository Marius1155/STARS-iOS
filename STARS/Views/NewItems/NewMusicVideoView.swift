//
//  NewMusicVideoView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 15.09.2024.
//

import SwiftUI

struct NewMusicVideoView: View {
    /*@EnvironmentObject var dataManager: DataManager
    
    @State private var sortedSongs: [Song] = []
    
    @State private var musicVideoSongsCount = 1
    @State private var musicVideoSongsIDs: [String] = [""]
    @State private var releaseDate: Date = Date()
    @State private var youtube: String = ""
    
    @State private var showMusicVideoAlert: Bool = false*/
    
    var body: some View {
        /*Section("New Music Video") {
            DatePicker("Release date", selection: $releaseDate, displayedComponents: .date)
            
            TextField("Youtube", text: $youtube)
        }
        .onAppear {
            sortedSongs = dataManager.songs.sorted { $0.title.lowercased() < $1.title.lowercased() }
        }
        
        Section("Songs") {
            HStack {
                Text("Belonging to ")
                
                Button {
                    musicVideoSongsCount -= 1
                    musicVideoSongsIDs.removeLast()
                } label: {
                    Image(systemName: "minus.circle.fill")
                }
                .font(.title2)
                .disabled(musicVideoSongsCount <= 1)
                .buttonStyle(BorderlessButtonStyle())
                
                Text("\(musicVideoSongsCount)")
                
                Button {
                    musicVideoSongsCount += 1
                    musicVideoSongsIDs.append("")
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .font(.title2)
                .buttonStyle(BorderlessButtonStyle())
                
                Text(musicVideoSongsCount == 1 ? "song" : "songs")
            }
            
            ForEach(0..<musicVideoSongsCount, id: \.self) { index in
                Picker("Song \(index + 1)", selection: $musicVideoSongsIDs[index]){
                    Text("None")
                        .tag("")
                    ForEach(sortedSongs) { song in
                        Text(songLongFormat(song: song))
                            .tag(song.id!)
                    }
                }
            }
        }
        
        Section() {
            HStack {
                Spacer()
                
                Button {
                    if youtube == "" || musicVideoSongsIDs.contains(where: { $0 == "" }){
                        showMusicVideoAlert.toggle()
                    }
                    
                    else {
                        let musicVideoID = dataManager.addMusicVideo(youtube: youtube, releaseDate: releaseDate, songs: musicVideoSongsIDs, outfits: [])
                        for song in musicVideoSongsIDs {
                            dataManager.makeMusicVideoBelongToSong(song: song, musicVideo: musicVideoID)
                        }
                        youtube = ""
                        releaseDate = Date()
                        musicVideoSongsCount = 1
                        musicVideoSongsIDs.removeAll()
                        musicVideoSongsIDs.append("")
                        
                        sortedSongs = dataManager.songs.sorted { $0.title.lowercased() < $1.title.lowercased()
                        }
                    }
                } label: {
                    Text("Save")
                        .bold()
                }
                .alert("Dumb Bitch", isPresented: $showMusicVideoAlert) {
                    Button("I'm sorry, it won't happen again...", role: .cancel) { }
                } message: {
                    Text("You forgot to fill in some precious information")
                }
                
                Spacer()
            }
        }*/
    }
    
    /*func songLongFormat(song: Song) -> String {
        var result = song.title
        
        let artistNames = song.artist.map { dataManager.getArtistName(id: $0) }.joined(separator: ", ")
            result += " by \(artistNames)"
            
            // Add the features if there are any
            if !song.features.isEmpty {
                let featuredArtists = song.features.map { dataManager.getArtistName(id: $0) }.joined(separator: ", ")
                result += " feat. \(featuredArtists)"
            }
        
        return result
    }*/
}

#Preview {
    /*NewMusicVideoView()
        .environmentObject(DataManager())*/
}
