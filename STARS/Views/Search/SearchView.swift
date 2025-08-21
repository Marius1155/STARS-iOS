//
//  SearchView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 27.08.2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct SearchView: View {
    /*@State private var searchText: String = ""*/
    
    var body: some View {
        /*SearchView1(searchText: $searchText)
            .searchable(text: $searchText, placement:
                    .navigationBarDrawer(displayMode: .always), prompt: "Search")
            .navigationTitle("Search")*/
    }
}

struct SearchView1: View {
    /*@Environment(\.isSearching) private var isSearching
    @Binding var searchText: String
    
    @EnvironmentObject var dataManager: DataManager
    @AppStorage("userID") var userID: String = ""
    
    @State private var showPopup = false
    @State private var view: Int = 1
    @State private var isReady = false
    
    @State private var projects: [Project] = []
    @State private var musicVideos: [MusicVideo] = []
    @State private var podcasts: [Podcast] = []
    
    @State private var userIDs: [String] = []
    @State private var lastUserID: DocumentSnapshot? = nil
    @State private var passItOnAsLastUserID: DocumentSnapshot? = nil*/
    
    var body: some View {
        /*ScrollView {
            if isSearching {
                VStack {
                    Picker("", selection: $view) {
                        Image(systemName: "music.note").tag(1)
                        Image(systemName: "microphone.fill").tag(2)
                        Image(systemName: "tv").tag(3)
                        Image(systemName: "hanger").tag(4)
                        Image(systemName: "person.crop.circle").tag(5)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    if view == 5 {
                        Group {
                            if userIDs.isEmpty {
                                Spacer()
                                Text("No users found.")
                                Spacer()
                            }
                            
                            else {
                                ForEach(userIDs, id: \.self) { userID in
                                    ProfilePreview(profileID: userID)
                                    Divider()
                                }
                            }
                        }
                        .onAppear {
                            dataManager.fetchProfilesCarelesslyLikeYouDontHaveAWorryInTheWorldAndUsersToSatisfy() { fetchedProfileIDs in
                                userIDs = fetchedProfileIDs.filter { $0 != userID }
                                print("yass")
                            }
                        }
                    }
                }
            } else {
                if !isReady {
                    Spacer()
                    ProgressView()
                        .frame(width: 100, height: 100)
                    Spacer()
                }
                else {
                    VStack {
                            HStack {
                                Text("Featured Projects")
                                    .font(.title2)
                                    .bold()
                                /*.padding(5)
                                 .background {
                                 RoundedRectangle(cornerRadius: 10)
                                 .foregroundColor(.accentColor)
                                 .shadow(radius: 10)
                                 }*/
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach($projects) { $project in
                                        NavigationLink{
                                            ProjectDetailView(project: $project)
                                        } label: {
                                            ProjectPreview(project: project)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            HStack {
                                Text("Featured Music Videos")
                                    .font(.title2)
                                    .bold()
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(musicVideos) { musicVideo in                                        NavigationLink{
                                        MusicVideoDetailView(musicVideo: musicVideo)
                                    } label: {
                                        MusicVideoPreview(musicVideo: musicVideo)
                                            .foregroundColor(.primary)
                                    }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            /*ScrollView{
                             VStack(alignment: .leading) {
                             ForEach(dataManager.songs) { song in
                             NavigationLink {
                             SongDetailView(song: song)
                             } label: {
                             HStack{
                             let image = dataManager.getProject(id: song.projectsPartOf.first!)!.cover
                             WebImage(url: URL(string: image))
                             .resizable()
                             .frame(width: 64, height: 64)
                             .clipShape(RoundedRectangle(cornerRadius: 7))
                             .shadow(radius: 10)
                             
                             VStack(alignment: .leading) {
                             SongTitleView(song: song)
                             .lineLimit(1)
                             .truncationMode(.tail)
                             SongArtistNameView(song: song)
                             .lineLimit(1)
                             .truncationMode(.tail)
                             }
                             }
                             }
                             }
                             }
                             }
                             .frame(height:300)*/
                            HStack {
                                Text("Featured Podcasts")
                                    .font(.title2)
                                    .bold()
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(podcasts) { podcast in
                                        NavigationLink{
                                            PodcastDetailView(podcast: podcast)
                                        } label: {
                                            PodcastPreview(podcast: podcast)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        
                        /*if view == 3 {
                         List {
                         ForEach(dataManager.artists) { artist in
                         if artist.isFeatured {
                         NavigationLink {
                         ArtistDetailView(artist: artist)
                         } label: {
                         HStack{
                         WebImage(url: URL(string: artist.picture))
                         .resizable()
                         .scaledToFill()
                         .frame(width: 64, height: 64)
                         .clipShape(Circle())
                         .shadow(radius: 10)
                         
                         VStack(alignment: .leading) {
                         Text(artist.name)
                         .font(.headline)
                         .bold()
                         .lineLimit(1)
                         .truncationMode(.tail)
                         Text(artist.pronouns)
                         .italic()
                         .lineLimit(1)
                         .truncationMode(.tail)
                         }
                         }
                         }
                         }
                         }
                         }
                         }*/
                        Spacer()
                    }
                    /*.navigationTitle("Browse")
                    .searchable(text: $searchText, isPresented: $isSearchFieldFocused, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
                    .searchPresentationToolbarBehavior(.automatic)*/
                }
            }
        }
        .onAppear{
            DispatchQueue.main.async {
                dataManager.fetchFeaturedProjects() {fetchedProjects in
                    projects = fetchedProjects
                    
                    dataManager.fetchFeaturedMusicVideos() {fetchedMusicVideos in
                        musicVideos = fetchedMusicVideos
                        
                        dataManager.fetchFeaturedPodcasts() {fetchedPodcasts in
                            podcasts = fetchedPodcasts
                            isReady = true
                        }
                    }
                }
            }
        }*/
    }
}

#Preview {
    /*SearchView()
        .environmentObject(DataManager())
        .onAppear {
            UserDefaults.standard.set(true, forKey: "userIsLoggedIn")
            UserDefaults.standard.set("AX7ztju3UBWYsTXCXfFsYFCcJSl2", forKey: "userID")
            UserDefaults.standard.set("Marius115", forKey: "userTag")
            UserDefaults.standard.set(true, forKey: "userHasPremium")
            UserDefaults.standard.set("mariusgabrielbudai@gmail.com", forKey: "userEmail")
            UserDefaults.standard.set("He/Him", forKey: "userPronouns")
            UserDefaults.standard.set("https://firebasestorage.googleapis.com:443/v0/b/fir-8a33f.appspot.com/o/banners%2FAX7ztju3UBWYsTXCXfFsYFCcJSl2.jpg?alt=media&token=733eb320-df39-4814-8246-45724befdfe3", forKey: "userBannerPicture")
            UserDefaults.standard.set("https://firebasestorage.googleapis.com:443/v0/b/fir-8a33f.appspot.com/o/profile_pictures%2FAX7ztju3UBWYsTXCXfFsYFCcJSl2.jpg?alt=media&token=ae930d67-ae62-475f-beab-976cac6fa102", forKey: "userProfilePicture")
            UserDefaults.standard.set(true, forKey: "userIsAdmin")
        }*/
}
