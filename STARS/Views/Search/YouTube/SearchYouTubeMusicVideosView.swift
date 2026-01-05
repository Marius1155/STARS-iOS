//
//  SearchMusicVideosView.swift
//  STARS
//
//  Created by Marius Gabriel Budai on 24.10.2025.
//

import SwiftUI
import STARSAPI

struct SearchYouTubeMusicVideosView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var videos: [STARSAPI.SearchYoutubeVideosQuery.Data.SearchYoutubeVideo] = []
    @State var searchText: String
    
    var body: some View {
        VStack {
            if searchText.isEmpty && videos.isEmpty {
                emptyStatePlaceholder
            }
            else if !searchText.isEmpty && videos.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
            else {
                ScrollView {
                    VStack {
                        ForEach(videos, id: \.id) { video in
                            NavigationLink {
                                YouTubeMusicVideoDetailView(youtubeVideoId: video.id, youtubeVideoTitle: video.title, youtubeVideoThumbnailUrl: video.thumbnailUrl, youtubeVideoChannelName: video.channelName, youtubeVideoPublishedAt: video.publishedAt, youtubeVideoLengthMs: video.lengthMs, youtubeVideoViewCount: video.viewCount, youtubeVideoUrl: video.url, youtubeVideoPrimaryColor: video.primaryColor)
                            } label: {
                                MusicVideoListPreview(
                                    youtubeVideo: video
                                )
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search music videos")
        .task(id: searchText) {
            if searchText.isEmpty {
                videos.removeAll()
                return
            }
           
            // 1. Debounce
            do {
                try await Task.sleep(for: .milliseconds(250))
            } catch {
                return
            }
           
            // 2. Perform API call
            fetchVideos(term: searchText)
        }
        .navigationTitle("Search Music Videos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Search Music Videos")
                    .font(.headline)
                    .foregroundColor(.clear)
            }
        }
    }
    
    @ViewBuilder
    var emptyStatePlaceholder: some View {
        VStack(spacing: 24) {
            Spacer()
            Spacer()
            
            Image("YouTubeLogoRed")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)
                .shadow(color: colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.bottom, -20)
            
            VStack(spacing: 8) {
                Text("Search YouTube")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
                
                Text("Find music videos to add to the database.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
            Spacer()
        }
    }
    
    func fetchVideos(term: String) {
        let query = STARSAPI.SearchYoutubeVideosQuery(term: term)
        
        Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
            switch result {
            case .success(let graphQLResult):
                if let fetchedVideos = graphQLResult.data?.searchYoutubeVideos {
                    DispatchQueue.main.async {
                        self.videos = fetchedVideos
                    }
                } else if let errors = graphQLResult.errors {
                    print("GraphQL errors:", errors)
                }
            case .failure(let error):
                print("Error fetching YouTube videos: \(error)")
            }
        }
    }
}

#Preview {
    NavigationView {
        SearchYouTubeMusicVideosView(searchText: "")
    }
}
