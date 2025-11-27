//
//  PodcastHostsView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 02.10.2024.
//

import SwiftUI

struct PodcastHostsView: View {
    /* 
    let podcast: Podcast
    var linkToHosts = false
    @State private var artists: [Artist] = []*/
    
    var body: some View {
        /*HStack {
            if linkToHosts {
                ForEach(Array(artists.enumerated()), id: \.element.id) { index, artist in
                    NavigationLink {
                        ArtistDetailView(artist: artist)
                    } label: {
                        Text(artist.name)
                    }
                    
                    if index < artists.count - 1 {
                        Text("&")
                    }
                }
            }
            
            else {
                let hostsNames = artists.map { $0.name }.joined(separator: " & ")
                
                Text(hostsNames)
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                dataManager.fetchArtists(withIDs: podcast.hosts) { fetchedArtists in
                    artists = fetchedArtists
                }
            }
        }*/
    }
}

#Preview {
    /*PodcastHostsView(podcast: Podcast(id: "", title: "", by: "", hosts: [], since: Date(), covers: [], website: "", reviews: [], reviewsCount: 0, starAverage: 0, sequels: [], isFeatured: false))
         */
}
