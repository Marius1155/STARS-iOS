//
//  NewPodcastView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 23.09.2024.
//

import SwiftUI

struct NewPodcastView: View {
    /*@EnvironmentObject var dataManager: DataManager
    
    @State private var sortedArtists: [Artist] = []
    @State private var sortedPodcasts: [Podcast] = []
    
    @State private var podcastHostsCount = 1
    @State private var podcastSequelsCount = 0
    
    @State private var title: String = ""
    @State private var by: String = ""
    @State private var hosts: [String] = [""]
    @State private var since: Date = Date()
    @State private var cover: String = ""
    @State private var website: String = ""
    @State private var sequels: [String] = []
    
    @State private var showPodcastAlert: Bool = false*/
    
    var body: some View {
        /*Section("New Podcast") {
            TextField("Title", text: $title)
            
            TextField("By", text: $by)
            
            DatePicker("Since", selection: $since, displayedComponents: .date)
            
            TextField("Cover", text: $cover)
            
            TextField("Website", text: $website)
        }
        .onAppear {
            sortedArtists = dataManager.artists.sorted { $0.name.lowercased() < $1.name.lowercased() }
            
            sortedPodcasts = dataManager.podcasts.sorted { $0.title.lowercased() < $1.title.lowercased() }
        }
        
        Section("Sequels") {
            HStack {
                Text("Number of sequels: ")
                
                Button {
                    podcastSequelsCount -= 1
                    sequels.removeLast()
                } label: {
                    Image(systemName: "minus.circle.fill")
                }
                .font(.title2)
                .disabled(podcastSequelsCount <= 0)
                .buttonStyle(BorderlessButtonStyle())
                
                Text("\(podcastSequelsCount)")
                
                Button {
                    podcastSequelsCount += 1
                    sequels.append("")
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .font(.title2)
                .buttonStyle(BorderlessButtonStyle())
            }
            
            ForEach(0..<podcastSequelsCount, id: \.self) { index in
                Picker("Podcast \(index + 1)", selection: $sequels[index]){
                    Text("None")
                        .tag("")
                    ForEach(sortedPodcasts) { podcast in
                        Text(podcastLongFormat(podcast: podcast))
                            .tag(podcast.id!)
                    }
                }
            }
        }
    
        Section("Hosts") {
            HStack {
                Text("Featuring ")
                
                Button {
                    podcastHostsCount -= 1
                    hosts.removeLast()
                } label: {
                    Image(systemName: "minus.circle.fill")
                }
                .font(.title2)
                .disabled(podcastHostsCount <= 1)
                .buttonStyle(BorderlessButtonStyle())
                
                Text("\(podcastHostsCount)")
                
                Button {
                    podcastHostsCount += 1
                    hosts.append("")
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .font(.title2)
                .buttonStyle(BorderlessButtonStyle())
                
                Text(podcastHostsCount == 1 ? "host" : "hosts")
            }
            
            ForEach(0..<podcastHostsCount, id: \.self) { index in
                Picker("Host \(index + 1)", selection: $hosts[index]){
                    Text("None")
                        .tag("")
                    ForEach(sortedArtists) { artist in
                        Text(artist.name)
                            .tag(artist.id!)
                    }
                }
            }
        }
        
        Section() {
            HStack {
                Spacer()
                
                Button {
                    if title == "" || by == "" || hosts.contains(where: { $0 == "" }) || cover == "" || sequels.contains(where: { $0 == "" }){
                        showPodcastAlert.toggle()
                    }
                    
                    else {
                        let podcastID = dataManager.addPodcast(title: title, by: by, hosts: hosts, since: since, covers: [cover], website: website, sequels: sequels)
                        
                        for sequelID in sequels {
                            dataManager.makePodcastSequelOfAnotherPodcast(podcastID: podcastID, sequelID: sequelID)
                        }
                        
                        for hostID in hosts {
                            dataManager.makeArtistBeHostOfAPodcast(podcastID: podcastID, artistID: hostID)
                        }
                        
                        podcastHostsCount = 1
                        podcastSequelsCount = 0
                        
                        title = ""
                        by = ""
                        hosts = [""]
                        since = Date()
                        cover = ""
                        website = ""
                        sequels = []
                        
                        sortedArtists = dataManager.artists.sorted { $0.name.lowercased() < $1.name.lowercased() }
                        
                        sortedPodcasts = dataManager.podcasts.sorted { $0.title.lowercased() < $1.title.lowercased() }
                    }
                } label: {
                    Text("Save")
                        .bold()
                }
                .alert("Dumb Bitch", isPresented: $showPodcastAlert) {
                    Button("I'm sorry, it won't happen again...", role: .cancel) { }
                } message: {
                    Text("You forgot to fill in some precious information")
                }
                
                Spacer()
            }
        }*/
    }
    /*
    func podcastLongFormat(podcast: Podcast) -> String {
        var result = podcast.title
        
        let hostsNames = podcast.hosts.map { dataManager.getArtistName(id: $0) }.joined(separator: ", ")
            result += " by \(hostsNames)"
        
        return result
    }*/
}

#Preview {
    /*NewPodcastView()
        .environmentObject(DataManager())*/
}
