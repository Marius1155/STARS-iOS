//
//  MusicVideoDetailView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 02.10.2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct MusicVideoDetailView: View {
    /*@EnvironmentObject var dataManager: DataManager
    
    @State private var showMusicVideoReviews = false
    @State private var showNewReview = false
    
    var musicVideo: MusicVideo
    
    @State private var songsOfMusicVideo: [Song] = []
    
    @State private var videoTitle: String = "Loading..."
    @State private var channelName: String = "Loading..."
    @State private var thumbnailURL: String = ""
    
    var videoID: String? {
        if let url = URL(string: musicVideo.youtube), let host = url.host, host.contains("youtube.com") {
            return url.query?.components(separatedBy: "v=").last
        } else if let url = URL(string: musicVideo.youtube), let host = url.host, host.contains("youtu.be") {
            return url.pathComponents.last
        }
        return nil
    }*/
    
    var body: some View {
        /*ScrollView {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.accentColor)
                        .frame(width: 350, height: 225)
                        .shadow(radius: 5)
                    
                    if let videoID = videoID, !thumbnailURL.isEmpty {
                        WebImage(url: URL(string: thumbnailURL))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 336, height: 189)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 5)
                    } else {
                        Rectangle()
                            .foregroundColor(.gray)
                            .frame(width: 336, height: 189)
                            .cornerRadius(10)
                    }
                }
                //.padding(.top, -50)
                    
                Text(videoTitle)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                
                Link(destination: URL(string: musicVideo.youtube)!) {
                    HStack {
                        Text("Watch on YouTube")
                        Image(systemName: "play.rectangle.fill")
                            .padding(.leading, -5)
                    }
                    .font(.title3)
                }
                
                HStack {
                    let calendar = Calendar.current
                    let releaseYear = calendar.component(.year, from: musicVideo.releaseDate)
                    
                    Image(systemName: "music.note.tv.fill")
                        .bold()
                    Text("Music Video")
                    
                    Text("•")
                        .bold()
                    
                    Text(String(releaseYear))
                    
                    if musicVideo.songs.count != 1 {
                        Text("•")
                            .bold()
                        
                        Text("\(musicVideo.songs.count) tracks")
                    }
                    
                    /*Text("•")
                        .bold()
                    
                    if project.length == 1 {
                        Text("1 minute")
                    }
                    
                    else {
                        Text("\(project.length) minutes")
                    }
                    */
                }
                
                let stars = dataManager.getMusicVideoAverageStars(musicVideo: musicVideo)
                HStack(spacing: 2) {
                    NavigationLink {
                        MusicVideoReviewsView(musicVideo: musicVideo)
                    } label: {
                        HStack(spacing: 0) {
                            StarView(stars: stars)
                            
                            Text(String(format: "%.1f", stars))
                                .foregroundColor(.black)
                                .frame(minWidth: 30)
                        }
                    }
                    .bold()
                    .font(.headline)
                    .frame(minWidth: 60, maxWidth: .infinity, minHeight: 25)
                    .padding(.horizontal, 35)
                    .padding(.vertical, 10)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 5)
                    }
                    
                    Spacer()
                    
                    if musicVideo.reviews.count == 1 {
                        Text("(1 review)")
                            .font(.callout)
                            .italic()
                    }
                    
                    else {
                        Text("(\(musicVideo.reviews.count) reviews)")
                            .font(.callout)
                            .italic()
                    }
                    
                    Spacer()
                    
                    Button {
                        showNewReview.toggle()
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "plus.app.fill")
                            
                            VStack(spacing: 0) {
                                Text("Add")
                                Text("review")
                            }
                            .foregroundColor(.black)
                            .font(.subheadline)
                            .bold()
                        }
                    }
                    .padding(5)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 5)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.accentColor)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 5)
                .padding(.bottom, 15)
                .padding(.top, 2)
                
                Divider()
                    .padding(.horizontal)
                
                ForEach(Array(songsOfMusicVideo.enumerated()), id: \.element.id) {index, song in
                    HStack{
                        Text("\(index + 1). ")
                        VStack(alignment: .leading) {
                            SongTitleView(song: song, linkToFeatures: true, linkToSong: false)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            SongArtistNameView(song: song, linkToArtists: true)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        
                        Spacer()
                        
                        NavigationLink {
                            SongReviewsView(song: songsOfMusicVideo[index])
                        } label: {
                            
                            HStack {
                                Text(String(format: "%.1f", dataManager.getSongAverageStars(song: song)))
                                    .foregroundColor(.black)
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                        .bold()
                        .font(.subheadline)
                        .padding(10)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(radius: 5)
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background{
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.accentColor)
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
        
                    Divider()
                        .padding(.horizontal)
                }
            }
            .onAppear {
                fetchYouTubeData()
                songsOfMusicVideo = dataManager.getSongsOfAnAlbum(songIDs: musicVideo.songs) // its called album but it also works for MVs *insert eyes emoji*
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        
        .sheet(isPresented: $showNewReview, content: {
            NewMusicVideoReviewView(musicVideo: musicVideo)
                .presentationDetents([.large])
                .interactiveDismissDisabled()
        })*/
    }
    /*
    func fetchYouTubeData() {
        guard let videoID = videoID else {
            return
        }
        
        let apiKey = ""
        let urlString = "https://www.googleapis.com/youtube/v3/videos?id=\(videoID)&part=snippet&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                // Parse the response
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let items = json["items"] as? [[String: Any]],
                   let snippet = items.first?["snippet"] as? [String: Any] {
                    
                    DispatchQueue.main.async {
                        videoTitle = snippet["title"] as? String ?? "Unknown Title"
                        channelName = snippet["channelTitle"] as? String ?? "Unknown Channel"
                        thumbnailURL = "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg"
                    }
                }
            } catch {
                print("Failed to parse JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }*/
}

#Preview {
    /*@Previewable @EnvironmentObject var dataManager: DataManager
    MusicVideoDetailView(musicVideo: dataManager.musicVideos.first!)
        .environmentObject(DataManager())*/
}
