//
//  MusicVideoReviewsView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 28.08.2024.
//

import SwiftUI

struct MusicVideoReviewsView: View {
    /*@Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    var musicVideo: MusicVideo
    @State private var showSubreviews: [Bool] = [false]
    @State private var showButton: [Bool] = [true]
    @State private var showNewReviewView: Bool = false
    
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
        /*let reviews = dataManager.getMusicVideoReviews(reviewsIDs: musicVideo.reviews)
        
        VStack {
            List {
                HStack {
                    Image(systemName: "music.note.tv.fill")
                    
                    Text(videoTitle)
                        .bold()
                }
                .listRowSeparator(.hidden)
                
                HStack{
                    Spacer()
                    Text("•")
                        .bold()
                    Text("\(reviews.count) reviews")
                        .italic()
                    Text("•")
                        .bold()
                    Spacer()
                }
                .background{
                    RibbonShape()
                        .fill(Color.accentColor)
                        .frame(height: 30)
                    //.shadow(radius: 2)
                }
                .padding(.top, 5)
                .listRowSeparator(.hidden)
                
                
                ForEach(Array(reviews.enumerated()), id: \.element.id) {index, review in
                    VStack(alignment: .leading) {
                        HStack {
                            StarView(stars: review.stars)
                                .bold()
                            
                            Text(String(format: "%.1f", review.stars))
                                .bold()
                            
                            Spacer()
                            
                            Text("by:")
                                .italic()
                            
                            Text(review.user)
                                .bold()
                        }
                        
                        Divider()
                        
                        Text(review.text)
                        
                        if showSubreviews[index] {
                            VStack(alignment: .leading) {
                                ForEach(0..<review.subreviewsTopics.count, id: \.self) { index in
                                    Divider()
                                    
                                    HStack {
                                        Text(review.subreviewsTopics[index])
                                            .bold()
                                        
                                        StarView(stars: review.subreviewsStars[index])
                                            .bold()
                                        
                                        Text(String(format: "%.1f", review.subreviewsStars[index]))
                                            .bold()
                                    }
                                    
                                    if review.subreviewsTexts[index] != "" {
                                        Text(review.subreviewsTexts[index])
                                            .lineLimit(nil)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                        
                        HStack{
                            if !review.subreviewsTopics.isEmpty{
                                Button {
                                    //withAnimation {
                                    showButton[index].toggle()
                                    showSubreviews[index].toggle()
                                    //}
                                } label: {
                                    Text(showButton[index] ? "Show subreviews" : "Hide subreviews")
                                }
                                .font(.footnote)
                                .buttonStyle(BorderlessButtonStyle())
                                
                            }
                            
                            Spacer()
                            
                            Text(review.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.footnote)
                        }
                        .padding(.top, 3)
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                            .shadow(radius: 5)
                    }
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(PlainListStyle())
        }
        .onAppear {
            fetchYouTubeData()
            showSubreviews = Array(repeating: false, count: reviews.count)
            showButton = Array(repeating: true, count: reviews.count)
        }
        .navigationTitle("MV reviews")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button() {
                    
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button() {
                    showNewReviewView.toggle()
                } label: {
                    Image(systemName: "plus")
                        .bold()
                }
            }
        }
        .sheet(isPresented: $showNewReviewView, content: {
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
        
        let apiKey = "AIzaSyDMXnvh0DRlv8cudxiu7dRb6XNcNGxDX9M"
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
    MusicVideoReviewsView(musicVideo: dataManager.musicVideos.first!)
        .environmentObject(DataManager())*/
}
