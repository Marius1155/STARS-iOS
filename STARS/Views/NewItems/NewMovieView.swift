//
//  NewMovieView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 22.09.2024.
//

import SwiftUI

struct NewMovieView: View {
    /* 
    
    @State private var sortedArtists: [Artist] = []
    @State private var sortedMovies: [Movie] = []
    
    @State private var movieActorsCount = 0
    @State private var movieActorsIDs: [String] = []
    @State private var movieSequelsCount = 0
    @State private var movieSequelsIDs: [String] = []
    
    @State private var title: String = ""
    @State private var releaseDate: Date = Date()
    @State private var cover: String = ""
    @State private var wikipedia: String = ""
    @State private var trailer: String = ""
    @State private var lengthString: String = ""
    @State private var length: Int = 0
    
    @State private var showMovieAlert: Bool = false*/
    
    var body: some View {
        /*Section("New Movie") {
            TextField("Title", text: $title)
            DatePicker("Release date", selection: $releaseDate, displayedComponents: .date)
            TextField("Cover", text: $cover)
            TextField("Wikipedia", text: $wikipedia)
            TextField("Trailer", text: $trailer)
            HStack {
                TextField("Length", text: $lengthString)
                    .keyboardType(.numberPad)
                
                Text("minutes")
            }
        }
        .onAppear {
            sortedArtists = dataManager.artists.sorted { $0.name.lowercased() < $1.name.lowercased() }
            
            sortedMovies = dataManager.movies.sorted { $0.title.lowercased() < $1.title.lowercased() }
        }
        
        Section("Sequels") {
            HStack {
                Text("Number of sequels: ")
                
                Button {
                    movieSequelsCount -= 1
                    movieSequelsIDs.removeLast()
                } label: {
                    Image(systemName: "minus.circle.fill")
                }
                .font(.title2)
                .disabled(movieSequelsCount <= 0)
                .buttonStyle(BorderlessButtonStyle())
                
                Text("\(movieSequelsCount)")
                
                Button {
                    movieSequelsCount += 1
                    movieSequelsIDs.append("")
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .font(.title2)
                .buttonStyle(BorderlessButtonStyle())
            }
            
            ForEach(0..<movieSequelsCount, id: \.self) { index in
                Picker("Movie \(index + 1)", selection: $movieSequelsIDs[index]){
                    Text("None")
                        .tag("")
                    ForEach(sortedMovies) { movie in
                        Text(movie.title)
                            .tag(movie.id!)
                    }
                }
            }
        }
    
        Section("Actors") {
            HStack {
                Text("Featuring ")
                
                Button {
                    movieActorsCount -= 1
                    movieActorsIDs.removeLast()
                } label: {
                    Image(systemName: "minus.circle.fill")
                }
                .font(.title2)
                .disabled(movieActorsCount <= 0)
                .buttonStyle(BorderlessButtonStyle())
                
                Text("\(movieActorsCount)")
                
                Button {
                    movieActorsCount += 1
                    movieActorsIDs.append("")
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .font(.title2)
                .buttonStyle(BorderlessButtonStyle())
                
                Text(movieActorsCount == 1 ? "actor" : "actors")
            }
            
            ForEach(0..<movieActorsCount, id: \.self) { index in
                Picker("Actor \(index + 1)", selection: $movieActorsIDs[index]){
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
                    if title == "" || cover == "" || wikipedia == "" || trailer == "" || lengthString == "" || lengthString == "0" || movieActorsIDs.contains(where: { $0 == "" }) || movieSequelsIDs.contains(where: { $0 == "" }){
                        showMovieAlert.toggle()
                    }
                    
                    else {
                        length = Int(lengthString)!
                        let movieID = dataManager.addMovie(title: title, actors: movieActorsIDs, releaseDate: releaseDate, covers: [cover], wikipedia: wikipedia, trailer: trailer, length: length, sequels: movieSequelsIDs, relatedSeries: [], soundtrackProjects: [], soundtrackSongs: [], outfits: [])
                        
                        for sequelID in movieSequelsIDs {
                            dataManager.makeMovieASequelOfAnotherMovie(movieID: movieID, sequelID: sequelID)
                        }
                        
                        for actorID in movieActorsIDs {
                            dataManager.makeMoviePartOfActorsMoviesList(actorID: actorID, movieID: movieID)
                        }
                        
                        movieActorsCount = 0
                        movieActorsIDs = []
                        movieSequelsCount = 0
                        movieSequelsIDs = []
                        
                        title = ""
                        releaseDate = Date()
                        cover = ""
                        wikipedia = ""
                        trailer = ""
                        lengthString = ""
                        length = 0
                        
                        sortedArtists = dataManager.artists.sorted { $0.name.lowercased() < $1.name.lowercased() }
                        
                        sortedMovies = dataManager.movies.sorted { $0.title.lowercased() < $1.title.lowercased() }
                    }
                } label: {
                    Text("Save")
                        .bold()
                }
                .alert("Dumb Bitch", isPresented: $showMovieAlert) {
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
    /*NewMovieView()
         */
}
