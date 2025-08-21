//
//  NewOutfitView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 23.09.2024.
//

import SwiftUI

struct NewOutfitView: View {
    /*@EnvironmentObject var dataManager: DataManager
    
    @State private var sortedArtists: [Artist] = []
    @State private var sortedOutfits: [Outfit] = []
    
    @State private var outfitPicturesCount: Int = 1
    @State private var outfitMatchesCount: Int = 0
    
    @State private var event: String = ""
    @State private var person: String = ""
    @State private var date: Date = Date()
    @State private var pictures: [String] = [""]
    @State private var matches: [String] = []
    
    @State private var showOutfitAlert: Bool = false*/
    
    var body: some View {
       /* Section("New Outfit") {
            TextField("Event", text: $event)
            
            Picker("Person", selection: $person) {
                Text("None").tag("")
                ForEach(sortedArtists, id: \.self) { artist in
                    Text(artist.name).tag(artist.id!)
                }
            }
            
            DatePicker("Release date", selection: $date, displayedComponents: .date)
        }
        .onAppear {
            sortedArtists = dataManager.artists.sorted { $0.name.lowercased() < $1.name.lowercased() }
            
            sortedOutfits = dataManager.outfits.sorted { $0.event.lowercased() < $1.event.lowercased() }
        }
        
        Section("Pictures") {
            HStack {
                Text("Number of pictures: ")
                
                Button {
                    outfitPicturesCount -= 1
                    pictures.removeLast()
                } label: {
                    Image(systemName: "minus.circle.fill")
                }
                .font(.title2)
                .disabled(outfitPicturesCount <= 1)
                .buttonStyle(BorderlessButtonStyle())
                
                Text("\(outfitPicturesCount)")
                
                Button {
                    outfitPicturesCount += 1
                    pictures.append("")
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .font(.title2)
                .buttonStyle(BorderlessButtonStyle())
            }
            
            ForEach(0..<outfitPicturesCount, id: \.self) { index in
                TextField("Picture \(index + 1)", text: $pictures[index])
            }
        }
        
        Section("Matches") {
            HStack {
                Text("Number of matches: ")
                
                Button {
                    outfitMatchesCount -= 1
                    matches.removeLast()
                } label: {
                    Image(systemName: "minus.circle.fill")
                }
                .font(.title2)
                .disabled(outfitMatchesCount <= 0)
                .buttonStyle(BorderlessButtonStyle())
                
                Text("\(outfitMatchesCount)")
                
                Button {
                    outfitMatchesCount += 1
                    matches.append("")
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .font(.title2)
                .buttonStyle(BorderlessButtonStyle())
            }
            
            ForEach(0..<outfitMatchesCount, id: \.self) { index in
                Picker("Outfit \(index + 1)", selection: $matches[index]){
                    Text("None")
                        .tag("")
                    ForEach(sortedOutfits) { outfit in
                        Text(outfitLongFormat(outfit: outfit))
                            .tag(outfit.id!)
                    }
                }
            }
        }
        
        Section() {
            HStack {
                Spacer()
                
                Button {
                    if event == "" || person == "" || pictures.contains(where: { $0 == "" }) || matches.contains(where: { $0 == "" }){
                        showOutfitAlert.toggle()
                    }
                    
                    else {
                        let outfitID = dataManager.addOutfit(event: event, person: person, date: date, pictures: pictures, matches: matches, projectCovers: [], musicVideos: [], podcastCovers: [], movies: [], movieCovers: [], series: [], seriesCovers: [])
                        
                        for matchID in matches {
                            dataManager.makeOutfitBeAMatchToAnother(outfitID: outfitID, matchID: matchID)
                        }
                        
                        outfitPicturesCount = 1
                        outfitMatchesCount = 0
                        
                        event = ""
                        person = ""
                        date = Date()
                        pictures = [""]
                        matches = []
                        
                        sortedArtists = dataManager.artists.sorted { $0.name.lowercased() < $1.name.lowercased() }
                        
                        sortedOutfits = dataManager.outfits.sorted { $0.event.lowercased() < $1.event.lowercased() }
                    }
                } label: {
                    Text("Save")
                        .bold()
                }
                .alert("Dumb Bitch", isPresented: $showOutfitAlert) {
                    Button("I'm sorry, it won't happen again...", role: .cancel) { }
                } message: {
                    Text("You forgot to fill in some precious information")
                }
                
                Spacer()
            }
        }*/
    }
    /*
    func outfitLongFormat(outfit: Outfit) -> String {
        var result = dataManager.getArtistName(id: outfit.person)
        result += "; "
        result += outfit.event
        
        return result
    }*/
}

#Preview {
    /*NewOutfitView()
        .environmentObject(DataManager())*/
}
