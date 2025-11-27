//
//  NewProjectView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 27.08.2024.
//

import SwiftUI

struct NewProjectView: View {
    /* 
    
    @State private var sortedCovers: [ProjectCover] = []
    @State private var sortedArtists: [Artist] = []
    @State private var sortedProjects: [Project] = []
    @State private var sortedSongs: [Song] = []
    
    @State private var numberOfCovers = 1
    @State private var numberOfArtists = 1
    @State private var numberOfAlternativeVersions = 0
    
    @State private var title: String = ""
    @State private var artist: [String] = [""] //later
    @State private var numberOfSongs: Int = 1
    @State private var releaseDate: Date = Date()
    @State private var type: Int = 0
    @State private var songs: [String] = [""]
    @State private var cover: [String] = [""]
    @State private var lengthString: String = ""
    @State private var length: Int = 0
    @State private var alternativeVersions: [String] = []
    
    @State private var songsAreNew: [Bool] = [true] //true = new song, false = existing song
    @State private var songsNumberOfArtists: [Int] = [1]
    @State private var songsNumberOfAlternativeVersions: [Int] = [0]
    @State private var songsNumberOfFeatures: [Int] = [0]
    
    @State private var songsTitles: [String] = [""]
    @State private var songsArtists: [[String]] = [[""]]
    @State private var songsFeatures: [[String]] = [[]]
    @State private var songsLengthsMinutesString: [String] = [""]
    @State private var songsLengthsSecondsString: [String] = [""]
    @State private var songsReleaseDates: [Date] = [Date()]
    @State private var songsAlternativeVersions: [[String]] = [[]]
    
    @State private var showProjectAlert: Bool = false*/
    
    var body: some View {
        /*Section("New Project") {
            TextField("Title", text: $title)
            
            DatePicker("Release date", selection: $releaseDate, displayedComponents: .date)
                .onChange(of: releaseDate) { oldValue, newValue in
                    songsReleaseDates[0] = newValue
                }
            
            Picker("Type", selection: $type) {
                Text("None").tag(0)
                Text("Album").tag(1)
                Text("EP").tag(2)
                Text("Mixtape").tag(3)
                Text("Single").tag(4)
            }
            
            HStack {
                TextField("Length", text: $lengthString)
                    .keyboardType(.numberPad)
                
                Text("minutes")
            }
        }
        .onAppear {
            sortedCovers = dataManager.projectCovers.sorted { extractImageTitle(from: $0.image)!.lowercased() < extractImageTitle(from: $1.image)!.lowercased() }
            sortedArtists = dataManager.artists.sorted { $0.name.lowercased() < $1.name.lowercased() }
            sortedProjects = dataManager.projects.sorted { $0.title.lowercased() < $1.title.lowercased() }
            sortedSongs = dataManager.songs.sorted { $0.title.lowercased() < $1.title.lowercased() }
        }
        
        Section("Covers") {
            HStack {
                Text("Having: ")
                
                Button {
                    numberOfCovers -= 1
                    cover.removeLast()
                } label: {
                    Image(systemName: "minus.circle.fill")
                }
                .font(.title2)
                .disabled(numberOfCovers <= 1)
                .buttonStyle(BorderlessButtonStyle())
                
                Text("\(numberOfCovers)")
                
                Button {
                    numberOfCovers += 1
                    cover.append("")
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .font(.title2)
                .buttonStyle(BorderlessButtonStyle())
                
                Text(numberOfCovers == 1 ? "cover" : "covers")
            }
            
            ForEach(0..<numberOfCovers, id: \.self) { index in
                Picker("Cover \(index + 1)", selection: $cover[index]){
                    Text("None")
                        .tag("")
                    ForEach(sortedCovers) { cover in
                        Text(extractImageTitle(from: cover.image)!)
                            .tag(cover.id!)
                    }
                }
            }
        }
        
        Section("Artists") {
            HStack {
                Text("Belonging to")
                
                Button {
                    numberOfArtists -= 1
                    songsNumberOfArtists[0] -= 1
                    artist.removeLast()
                    songsArtists[0].removeLast()
                } label: {
                    Image(systemName: "minus.circle.fill")
                }
                .font(.title2)
                .disabled(numberOfArtists <= 1)
                .buttonStyle(BorderlessButtonStyle())
                
                Text("\(numberOfArtists)")
                
                Button {
                    numberOfArtists += 1
                    songsNumberOfArtists[0] += 1
                    artist.append("")
                    songsArtists[0].append("")
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .font(.title2)
                .buttonStyle(BorderlessButtonStyle())
                
                Text(numberOfArtists == 1 ? "artist" : "artists")
            }
            
            ForEach(0..<numberOfArtists, id: \.self) { index in
                Picker("Artist \(index + 1)", selection: $artist[index]){
                    Text("None")
                        .tag("")
                    ForEach(sortedArtists) { artist in
                        Text(artist.name)
                            .tag(artist.id!)
                    }
                }
                .onChange(of: artist[index]) { oldValue, newValue in
                    songsArtists[0][index] = newValue
                }
            }
        }
        
        Section("Alternative Versions") {
            HStack {
                Text("No. of alternative versions:")
                
                Button {
                    numberOfAlternativeVersions -= 1
                    alternativeVersions.removeLast()
                } label: {
                    Image(systemName: "minus.circle.fill")
                }
                .font(.title2)
                .disabled(numberOfAlternativeVersions <= 0)
                .buttonStyle(BorderlessButtonStyle())
                
                Text("\(numberOfAlternativeVersions)")
                
                Button {
                    numberOfAlternativeVersions += 1
                    alternativeVersions.append("")
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .font(.title2)
                .buttonStyle(BorderlessButtonStyle())
            }
            
            ForEach(0..<numberOfAlternativeVersions, id: \.self) { index in
                Picker("Project \(index + 1)", selection: $alternativeVersions[index]){
                    Text("None")
                        .tag("")
                    ForEach(sortedProjects) { project in
                        Text(projectLongFormat(project: project))
                            .tag(project.id!)
                    }
                }
            }
        }
        
        Section("Songs") {
            HStack {
                Text("Contains")
                
                Button {
                    numberOfSongs -= 1
                    songs.removeLast()
                    songsAreNew.removeLast()
                    songsTitles.removeLast()
                    songsArtists.removeLast()
                    songsFeatures.removeLast()
                    songsLengthsMinutesString.removeLast()
                    songsLengthsSecondsString.removeLast()
                    songsReleaseDates.removeLast()
                    songsAlternativeVersions.removeLast()
                    songsNumberOfArtists.removeLast()
                    songsNumberOfAlternativeVersions.removeLast()
                    songsNumberOfFeatures.removeLast()
                } label: {
                    Image(systemName: "minus.circle.fill")
                }
                .font(.title2)
                .disabled(numberOfSongs <= 1)
                .buttonStyle(BorderlessButtonStyle())
                
                Text("\(numberOfSongs)")
                
                Button {
                    numberOfSongs += 1
                    songs.append("")
                    songsAreNew.append(true)
                    songsTitles.append("")
                    songsArtists.append(artist)
                    songsFeatures.append([])
                    songsLengthsMinutesString.append("")
                    songsLengthsSecondsString.append("")
                    songsReleaseDates.append(releaseDate)
                    songsAlternativeVersions.append([])
                    songsNumberOfArtists.append(numberOfArtists)
                    songsNumberOfAlternativeVersions.append(0)
                    songsNumberOfFeatures.append(0)
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .font(.title2)
                .disabled(numberOfSongs >= 1 && type == 4)
                .buttonStyle(BorderlessButtonStyle())
                
                Text(numberOfSongs == 1 ? "song" : "songs")
            }
        }
        
        ForEach(0..<numberOfSongs, id: \.self) { index in
            Section() {
                Text("Song \(index + 1)")
                    .bold()
                
                Toggle("Is new", isOn: $songsAreNew[index])
                
                if songsAreNew[index] == true {
                    TextField("Title", text: $songsTitles[index])
                    
                    HStack {
                        Text("Length:")
                        
                        TextField("minutes", text: $songsLengthsMinutesString[index])
                            .keyboardType(.numberPad)
                        
                        Text(":")
                        
                        TextField("seconds", text: $songsLengthsSecondsString[index])
                            .keyboardType(.numberPad)
                    }
                    
                    DatePicker("Release date", selection: $songsReleaseDates[index], displayedComponents: .date)
                    
                    
                    HStack {
                        Text("Belonging to")
                            .bold()
                        
                        Button {
                            songsNumberOfArtists[index] -= 1
                            songsArtists[index].removeLast()
                        } label: {
                            Image(systemName: "minus.circle.fill")
                        }
                        .font(.title2)
                        .disabled(songsNumberOfArtists[index] <= 1)
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Text("\(songsNumberOfArtists[index])")
                        
                        Button {
                            songsNumberOfArtists[index] += 1
                            songsArtists[index].append("")
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                        .font(.title2)
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Text(songsNumberOfArtists[index] == 1 ? "artist" : "artists")
                    }
                    
                    ForEach(0..<songsNumberOfArtists[index], id: \.self) { index1 in
                        Picker("Artist \(index1 + 1)", selection: $songsArtists[index][index1]){
                            Text("None")
                                .tag("")
                            ForEach(sortedArtists) { artist in
                                Text(artist.name)
                                    .tag(artist.id!)
                            }
                        }
                    }
                    
                    HStack {
                        Text("No. of features:")
                            .bold()
                        
                        Button {
                            songsNumberOfFeatures[index] -= 1
                            songsFeatures[index].removeLast()
                        } label: {
                            Image(systemName: "minus.circle.fill")
                        }
                        .font(.title2)
                        .disabled(songsNumberOfFeatures[index] <= 0)
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Text("\(songsNumberOfFeatures[index])")
                        
                        Button {
                            songsNumberOfFeatures[index] += 1
                            songsFeatures[index].append("")
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                        .font(.title2)
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    
                    ForEach(0..<songsNumberOfFeatures[index], id: \.self) { index1 in
                        Picker("Artist \(index1 + 1)", selection: $songsFeatures[index][index1]){
                            Text("None")
                                .tag("")
                            ForEach(sortedArtists) { artist in
                                Text(artist.name)
                                    .tag(artist.id!)
                            }
                        }
                    }
                    
                    HStack {
                        Text("No. of alternative versions:")
                            .bold()
                        
                        Button {
                            songsNumberOfAlternativeVersions[index] -= 1
                            songsAlternativeVersions[index].removeLast()
                        } label: {
                            Image(systemName: "minus.circle.fill")
                        }
                        .font(.title2)
                        .disabled(songsNumberOfAlternativeVersions[index] <= 0)
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Text("\(songsNumberOfAlternativeVersions[index])")
                        
                        Button {
                            songsNumberOfAlternativeVersions[index] += 1
                            songsAlternativeVersions[index].append("")
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                        .font(.title2)
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    
                    ForEach(0..<songsNumberOfAlternativeVersions[index], id: \.self) { index1 in
                        VStack {
                            Picker("Song \(index1 + 1)", selection: $songsAlternativeVersions[index][index1]){
                                Text("None")
                                    .tag("")
                                ForEach(sortedSongs) { song in
                                    Text(songLongFormat(song: song))
                                        .tag(song.id!)
                                }
                            }
                        }
                    }
                }
                if songsAreNew[index] == false {
                    Picker("Song", selection: $songs[index]){
                        Text("None")
                            .tag("")
                        ForEach(sortedSongs) { song in
                            Text(songLongFormat(song: song))
                                .tag(song.id!)
                        }
                    }
                    .onChange(of: songs[index]) { oldValue, newValue in
                        songsNumberOfAlternativeVersions[index] = dataManager.getSongWithGivenID(id: newValue).alternativeVersions.count
                        
                        songsAlternativeVersions[index] = []
                        
                        for i in 0..<songsNumberOfAlternativeVersions[index] {
                            songsAlternativeVersions[index].append( dataManager.getSongWithGivenID(id: newValue).alternativeVersions[i])
                        }
                    }
                    
                    HStack {
                        Text("No. of alternative versions:")
                            .bold()
                        
                        //Get up, up on your feet
                        Button {
                            songsNumberOfAlternativeVersions[index] -= 1
                            songsAlternativeVersions[index].removeLast()
                        } label: {
                            Image(systemName: "minus.circle.fill")
                        }
                        .font(.title2)
                        //.disabled(songsNumberOfAlternativeVersions[index] <= dataManager.getSongWithGivenID(id: songs[index]).alternativeVersions.count)
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Text("\(songsNumberOfAlternativeVersions[index])")
                        
                        Button {
                            songsNumberOfAlternativeVersions[index] += 1
                            songsAlternativeVersions[index].append("")
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                        .font(.title2)
                        .buttonStyle(BorderlessButtonStyle())
                        //She's so problematique
                    }
                         
                    ForEach(0..<songsNumberOfAlternativeVersions[index], id: \.self) { index1 in
                        VStack {
                            Picker("Song \(index1 + 1)", selection: $songsAlternativeVersions[index][index1]){
                                Text("None")
                                    .tag("")
                                ForEach(sortedSongs) { song in
                                    Text(songLongFormat(song: song))
                                        .tag(song.id!)
                                }
                            }
                            .disabled(index1 < dataManager.getSongWithGivenID(id: songs[index]).alternativeVersions.count)
                        }
                    }
                }
            }
        }
        
        Section() {
            HStack {
                Spacer()
                
                Button {
                    justARegularButtonsDayToDayActivitiesWhyDoYouCareAboutItBitchStayOutOfItISaidSTAYOUTOFIT()
                } label: {
                    Text("Save")
                        .bold()
                }
                .alert("Dumb Bitch", isPresented: $showProjectAlert) {
                    Button("I'm sorry, it won't happen again...", role: .cancel) { }
                } message: {
                    Text("You forgot to fill in some precious information")
                }
                
                Spacer()
            }
        }*/
    }
    /*
    func justARegularButtonsDayToDayActivitiesWhyDoYouCareAboutItBitchStayOutOfItISaidSTAYOUTOFIT() {
        if title == "" || type == 0 || (0..<numberOfSongs).contains(where: { index in
            songsAreNew[index] == false && songs[index] == ""
        }) || cover.contains(where: { $0 == "" }) || lengthString == "" || alternativeVersions.contains(where: { $0 == "" }) || songsTitles.contains(where: { $0 == "" }) || songsArtists.contains(where: { row in row.contains("") }) || songsFeatures.contains(where: { row in row.contains("") }) || songsLengthsMinutesString.contains(where: { $0 == "" }) || songsLengthsSecondsString.contains(where: { $0 == "" }) || songsAlternativeVersions.contains(where: { row in row.contains("") }) {
            showProjectAlert.toggle()
        }
        
        else {
            for i in 0..<numberOfSongs {
                if songsAreNew[i] == true {
                    let lengthMinutes = Int(songsLengthsMinutesString[i])!
                    let lengthSeconds = Int(songsLengthsSecondsString[i])!
                    
                    let songID = dataManager.addSong(title: songsTitles[i], artist: songsArtists[i], features: songsFeatures[i], lengthMinutes: lengthMinutes, lengthSeconds: lengthSeconds, releaseDate: songsReleaseDates[i], alternativeVersions: songsAlternativeVersions[i], musicVideos: [], movies: [], series: [])
                    
                    songs[i] = songID
                    
                    for j in 0..<songsNumberOfArtists[i] {
                        dataManager.makeSongBelongToArtist(songID: songID, artistID: songsArtists[i][j])
                    }
                    
                    for j in 0..<songsNumberOfFeatures[i] {
                        dataManager.makeSongBelongToArtist(songID: songID, artistID: songsFeatures[i][j])
                    }
                    
                    for j in 0..<songsNumberOfAlternativeVersions[i] {
                        dataManager.makeSongAlternativeVersionOfAnotherSong(song1ID: songID, song2ID: songsAlternativeVersions[i][j])
                    }
                }
                
                else {
                    let initialNumberOfAlternativeVersions = dataManager.getSongWithGivenID(id: songs[i]).alternativeVersions.count
                    
                    for j in initialNumberOfAlternativeVersions..<songsNumberOfAlternativeVersions[i] {
                        dataManager.makeSongAlternativeVersionOfAnotherSong(song1ID: songsAlternativeVersions[i][j], song2ID: songs[i])
                        dataManager.makeSongAlternativeVersionOfAnotherSong(song1ID: songs[i], song2ID: songsAlternativeVersions[i][j])
                    }
                }
            }
            
            length = Int(lengthString)!
            
            let projectID = dataManager.addProject(title: title, artist: artist, numberOfSongs: numberOfSongs, releaseDate: releaseDate, type: type, songs: songs, cover: cover, length: length, alternativeVersions: alternativeVersions, movies: [], series: [])
            
            for i in 0..<numberOfArtists {
                dataManager.makeProjectBelongToArtist(projectID: projectID, artistID: artist[i])
            }
            
            for i in 0..<numberOfSongs {
                dataManager.makeSongPartOfProject(songID: songs[i], projectID: projectID)
            }
            
            for i in 0..<numberOfAlternativeVersions {
                dataManager.makeProjectAlternativeVersionOfAnotherProject(project1ID: projectID, project2ID: alternativeVersions[i])
            }
            
            for i in 0..<numberOfCovers {
                dataManager.makeProjectPartOfTheProjectsListOfACover(projectID: projectID, coverID: cover[i])
            }
            
            numberOfCovers = 1
            numberOfArtists = 1
            numberOfAlternativeVersions = 0
            
            title = ""
            artist = [""] //later
            numberOfSongs = 1
            releaseDate = Date()
            type = 0
            songs = [""]
            cover = [""]
            lengthString = ""
            length = 0
            alternativeVersions = []
            
            songsAreNew = [true]
            songsNumberOfArtists = [1]
            songsNumberOfAlternativeVersions = [0]
            songsNumberOfFeatures = [0]
            
            songsTitles = [""]
            songsArtists = [[""]]
            songsFeatures = [[]]
            songsLengthsMinutesString = [""]
            songsLengthsSecondsString = [""]
            songsReleaseDates = [Date()]
            songsAlternativeVersions = [[]]
            
            sortedCovers = dataManager.projectCovers.sorted { extractImageTitle(from: $0.image)!.lowercased() < extractImageTitle(from: $1.image)!.lowercased() }
            sortedArtists = dataManager.artists.sorted { $0.name.lowercased() < $1.name.lowercased() }
            sortedProjects = dataManager.projects.sorted { $0.title.lowercased() < $1.title.lowercased() }
            sortedSongs = dataManager.songs.sorted { $0.title.lowercased() < $1.title.lowercased() }
        }
    }
    
    func projectLongFormat(project: Project) -> String {
        var result = project.title
        
        let artistNames = project.artist.map { dataManager.getArtistName(id: $0) }.joined(separator: ", ")
            result += " by \(artistNames)"
        
        return result
    }
    
    func songLongFormat(song: Song) -> String {
        var result = song.title
        
        let artistNames = song.artist.map { dataManager.getArtistName(id: $0) }.joined(separator: ", ")
            result += " by \(artistNames)"
            
            // Add the features if there are any
            if !song.features.isEmpty {
                let featuredArtists = song.features.map { dataManager.getArtistName(id: $0) }.joined(separator: ", ")
                result += " feat. \(featuredArtists)"
            }
        
        return result
    }
    
    func extractImageTitle(from urlString: String) -> String? {
        guard let titleWithParams = urlString.components(separatedBy: "https://firebasestorage.googleapis.com/v0/b/fir-8a33f.appspot.com/o/").last?
            .components(separatedBy: "?").first else {
            return nil
        }
        return titleWithParams
    }*/
}

#Preview {
    /*Form {
        NewProjectView()
             
    }*/
}
