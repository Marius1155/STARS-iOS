//
//  PodcastListPreview.swift
//  STARS
//
//  Created by Marius Gabriel Budai on 29.12.2025.
//

import SwiftUI
import STARSAPI
import SDWebImageSwiftUI

struct PodcastListPreview: View {
    let id: String
    let title: String
    let coverUrl: String
    let host: String
    
    var body: some View {
        HStack {
            WebImage(url: URL(string: coverUrl))
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 2)
            
            VStack(alignment: .leading) {
                let combinedText = Text(Image(systemName: "microphone.fill")) + Text(" \(title)")

                combinedText
                    .bold()
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .truncationMode(.tail)
                
                Text(host)
                    .foregroundStyle(.gray)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            .padding(.leading, 4)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    PodcastListPreview(id: "1807308262", title: "Waveform: The MKBHD Podcast", coverUrl: "https://is1-ssl.mzstatic.com/image/thumb/Podcasts116/v4/87/20/86/87208638-42bf-a5b5-cfd5-6a55f85fc656/mza_105024973981456283.jpeg/900x900bb.jpg", host: "Vox Media Podcast Network")
}
