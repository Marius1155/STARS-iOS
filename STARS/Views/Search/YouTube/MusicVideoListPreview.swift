//
//  MusicVideoListPreview.swift
//  STARS
//
//  Created by Marius Gabriel Budai on 24.10.2025.
//

import SwiftUI
import STARSAPI
import SDWebImageSwiftUI

struct MusicVideoListPreview: View {
    let youtubeVideo: STARSAPI.SearchYoutubeVideosQuery.Data.SearchYoutubeVideo
    
    // ✅ CHANGED: Detect current color scheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top) {
            WebImage(url: URL(string: youtubeVideo.thumbnailUrl))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 67.5)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 2)
            
            VStack(alignment: .leading, spacing: 4) {
                // ✅ CHANGED: Image is now inline with text for better wrapping
                titleWithLogo
                    .bold()
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .font(.subheadline)
                
                Text("\(youtubeVideo.channelName) • \(formattedDate(youtubeVideo.publishedAt))")
                    .foregroundStyle(.gray)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
            }
            .padding(.leading, 4)
            .padding(.top, 2)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
    
    // Helper to create the combined Text view
    var titleWithLogo: Text {
        return Text(Image(systemName: "music.note.tv.fill")) + Text(" " + youtubeVideo.title)
    }
    
    func formattedDate(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        
        if let date = isoFormatter.date(from: dateString) {
            return date.formatted(.dateTime.year().month().day())
        }
        return ""
    }
}
