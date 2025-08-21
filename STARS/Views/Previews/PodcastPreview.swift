//
//  PodcastPreview.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 02.10.2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct PodcastPreview: View {
    /*@EnvironmentObject var dataManager: DataManager
    @State private var image: String = ""
    
    var podcast: Podcast*/
    
    var body: some View {
        /*VStack {
            if image != "" , let url = URL(string: image) {
                WebImage(url: url)
                    .resizable()
                    .frame(width: 148, height: 148)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 2)
            } else {
                ProgressView()
                    .frame(width: 148, height: 148)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            Text(podcast.title)
                .bold()
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 148, alignment: .leading)
                .padding(.bottom, -1)
            
            HStack {
                Group {
                    Text(String(format: "%.1f", podcast.starAverage))
                    + Text(Image(systemName: "star.fill"))
                        .foregroundColor(.yellow)
                }
                .padding(.trailing, -7)
                
                Text("•")
                    .bold()
                
                PodcastHostsView(podcast: podcast)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.leading, -5)
                
            }
            .foregroundColor(.gray)
            .font(.caption)
            .frame(width: 148, alignment: .leading)
            .padding(.bottom, 1)
        }
        .onAppear {
            DispatchQueue.main.async {
                dataManager.fetchPodcastCover(coverID: podcast.covers[0]) { podcastCover in
                    if let podcastCover = podcastCover {
                        print("Fetched project cover: \(podcastCover)")
                        image = podcastCover.image
                    } else {
                        print("Failed to fetch project cover.")
                    }
                }
            }
        }*/
    }
}

#Preview {
    /*@Previewable @EnvironmentObject var dataManager: DataManager
    PodcastPreview(podcast: dataManager.podcasts.first!)
        .environmentObject(DataManager())*/
}
