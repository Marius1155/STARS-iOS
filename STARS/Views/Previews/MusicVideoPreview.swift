//
//  MusicVideoPreview.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 02.10.2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct MusicVideoPreview: View {
    /*@EnvironmentObject var dataManager: DataManager
    
    var musicVideo: MusicVideo
    
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
        /*VStack {
            // YouTube thumbnail
            if let videoID = videoID, !thumbnailURL.isEmpty {
                WebImage(url: URL(string: thumbnailURL))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 112.5)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 5)
            } else {
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: 200, height: 120)
                    .cornerRadius(10)
            }
            
            // Video title
            Text(videoTitle)
                .font(.caption)
                .bold()
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 200, alignment: .leading)
                .padding(.bottom, -1)
            
            HStack {
                Group {
                    Text(String(format: "%.1f", musicVideo.starAverage))
                    + Text(Image(systemName: "star.fill"))
                        .foregroundColor(.yellow)
                }
                .padding(.trailing, -7)
                
                Text("•")
                    .bold()
                
                Text(channelName)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.leading, -5)
                    
            }
            .foregroundColor(.gray)
            .font(.caption)
            .frame(width: 200, alignment: .leading)
            .padding(.bottom, 1)
        }
        .onAppear {
            fetchYouTubeData()
        }
    }
    
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
        
        task.resume()*/
    }
}

#Preview {
    /*@Previewable @EnvironmentObject var dataManager: DataManager
    MusicVideoPreview(musicVideo: dataManager.musicVideos.first!)
        .environmentObject(DataManager())*/
}
