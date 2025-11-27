//
//  NewItemView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 12.09.2024.
//

import SwiftUI

struct NewItemView: View {
     
    @State private var type: Int = 1
    
    var body: some View {
        Form {
            HStack {
                Text("Item type: ")
                
                Picker("", selection: $type) {
                    Text("Artist").tag(1)
                    Text("Music Video").tag(2)
                    Text("Movie").tag(3)
                    Text("Outfit").tag(4)
                    Text("Podcast").tag(5)
                    Text("Project Cover").tag(6)
                    Text("Project").tag(7)
                    Text("TV Series").tag(8)
                }
            }
            
            if type == 1 {
                NewArtistView()
            }
            
            if type == 2 {
                NewMusicVideoView()
            }
            
            if type == 3 {
                NewMovieView()
            }
            
            if type == 4 {
                NewOutfitView()
            }
            
            if type == 5 {
                NewPodcastView()
            }
            
            if type == 6 {
                NewProjectCoverView()
            }
            
            if type == 7 {
                NewProjectView()
            }
            
            if type == 8 {
                NewTVSeriesView()
            }
        }
        .navigationTitle("New Item")
    }
}

#Preview {
    NewItemView()
}
