//
//  NewTVSeriesView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 23.09.2024.
//

import SwiftUI

struct NewTVSeriesView: View {
    /*@EnvironmentObject var dataManager: DataManager
    
    @State private var sortedArtists: [Artist] = []
    @State private var sortedTVSeries: [TVSeries] = []
    
    @State private var tvSeriesActorsCount = 0
    @State private var tvSeriesSequelsCount = 0
    
    @State private var title: String = ""
    @State private var actors: [String] = []
    @State private var releaseDate: Date = Date()
    @State private var cover: String = ""
    @State private var wikipedia: String = ""
    @State private var trailer: String = ""
    @State private var seasonsString: String = ""
    @State private var seasons: Int = 0
    @State private var episodesString: String = ""
    @State private var episodes: Int = 0
    @State private var sequels: [String] = []
    
    @State private var showTVSeriesAlert: Bool = false*/
    
    var body: some View {
        /*Section("New TV Series") {
            TextField("Title", text: $title)
            DatePicker("Release date", selection: $releaseDate, displayedComponents: .date)
            TextField("Cover", text: $cover)
            TextField("Wikipedia", text: $wikipedia)
            TextField("Trailer", text: $trailer)
            HStack {
                TextField("Number of seasons", text: $seasonsString)
                    .keyboardType(.numberPad)
                
                if seasonsString != "" {
                    Text("seasons")
                }
            }
            
            HStack {
                TextField("Number of episodes", text: $episodesString)
                    .keyboardType(.numberPad)
                
                if episodesString != "" {
                    Text("episodes")
                }
            }
        }
        .onAppear {
            sortedArtists = dataManager.artists.sorted { $0.name.lowercased() < $1.name.lowercased() }
            
            sortedTVSeries = dataManager.tvSeries.sorted { $0.title.lowercased() < $1.title.lowercased() }
        }
        
        Section("Sequels") {
            HStack {
                Text("Number of sequels: ")
                
                Button {
                    tvSeriesSequelsCount -= 1
                    sequels.removeLast()
                } label: {
                    Image(systemName: "minus.circle.fill")
                }
                .font(.title2)
                .disabled(tvSeriesSequelsCount <= 0)
                .buttonStyle(BorderlessButtonStyle())
                
                Text("\(tvSeriesSequelsCount)")
                
                Button {
                    tvSeriesSequelsCount += 1
                    sequels.append("")
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .font(.title2)
                .buttonStyle(BorderlessButtonStyle())
            }
            
            ForEach(0..<tvSeriesSequelsCount, id: \.self) { index in
                Picker("TV Series \(index + 1)", selection: $sequels[index]){
                    Text("None")
                        .tag("")
                    ForEach(sortedTVSeries) { tvSeries in
                        Text(tvSeries.title)
                            .tag(tvSeries.id!)
                    }
                }
            }
        }
    
        Section("Actors") {
            HStack {
                Text("Featuring ")
                
                Button {
                    tvSeriesActorsCount -= 1
                    actors.removeLast()
                } label: {
                    Image(systemName: "minus.circle.fill")
                }
                .font(.title2)
                .disabled(tvSeriesActorsCount <= 0)
                .buttonStyle(BorderlessButtonStyle())
                
                Text("\(tvSeriesActorsCount)")
                
                Button {
                    tvSeriesActorsCount += 1
                    actors.append("")
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .font(.title2)
                .buttonStyle(BorderlessButtonStyle())
                
                Text(tvSeriesActorsCount == 1 ? "actor" : "actors")
            }
            
            ForEach(0..<tvSeriesActorsCount, id: \.self) { index in
                Picker("Actor \(index + 1)", selection: $actors[index]){
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
                    if title == "" || cover == "" || wikipedia == "" || trailer == "" || seasonsString == "" || seasonsString == "0" || episodesString == "" || episodesString == "0" || actors.contains(where: { $0 == "" }) || sequels.contains(where: { $0 == "" }){
                        showTVSeriesAlert.toggle()
                    }
                    
                    else {
                        seasons = Int(seasonsString)!
                        episodes = Int(episodesString)!
                        let tvSeriesID = dataManager.addTVSeries(title: title, actors: actors, releaseDate: releaseDate, covers: [cover], wikipedia: wikipedia, trailer: trailer, seasons: seasons, episodes: episodes, sequels: sequels, relatedMovies: [], soundtrackProjects: [], soundtrackSongs: [], outfits: [])
                        
                        for sequelID in sequels {
                            dataManager.makeTVSeriesBeSequelOfAnotherTVSeries(tvSeriesID: tvSeriesID, sequelID: sequelID)
                        }
                        
                        for actorID in actors {
                            dataManager.makeTVSeriesBePartOfArtistsTVSeriesList(tvSeriesID: tvSeriesID, artistID: actorID)
                        }
                        
                        tvSeriesActorsCount = 0
                        tvSeriesSequelsCount = 0
                        
                        title = ""
                        actors = []
                        releaseDate = Date()
                        cover = ""
                        wikipedia = ""
                        trailer = ""
                        seasonsString = ""
                        seasons = 0
                        episodesString = ""
                        episodes = 0
                        sequels = []
                        
                        sortedArtists = dataManager.artists.sorted { $0.name.lowercased() < $1.name.lowercased() }
                        
                        sortedTVSeries = dataManager.tvSeries.sorted { $0.title.lowercased() < $1.title.lowercased() }
                    }
                } label: {
                    Text("Save")
                        .bold()
                }
                .alert("Dumb Bitch", isPresented: $showTVSeriesAlert) {
                    Button("I'm sorry, it won't happen again...", role: .cancel) { }
                } message: {
                    Text("You forgot to fill in some precious information")
                }
                
                Spacer()
            }
        }*/
    }
}

#Preview {
    /*NewTVSeriesView()
        .environmentObject(DataManager())*/
}
