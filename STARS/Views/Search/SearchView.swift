//
//  SearchView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 27.08.2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @State private var view: Int = 1 // 1: Music, 2: Podcasts, etc.
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. The Category Picker
            Picker("", selection: $view) {
                Image(systemName: "music.note").tag(1)
                Image(systemName: "microphone.fill").tag(2)
                Image(systemName: "hanger").tag(3)
                Image(systemName: "person.crop.circle").tag(4)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // 2. The Content View
            if view == 1 {
                MusicSearchContent(mainSearchText: $searchText)
            }
            else if view == 2 {
                PodcastsSearchContent(mainSearchText: $searchText)
            }
            else {
                // Placeholders for other tabs
                ContentUnavailableView("Coming Soon", systemImage: "hammer")
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Library")
        .navigationTitle("Search")
    }
}

// MARK: - Subview for Music Tab
struct MusicSearchContent: View {
    @Binding var mainSearchText: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // --- SECTION A: Local Results (Dummy Data) ---
                // This is where your actual local database results will go later
                if !mainSearchText.isEmpty {
                    Text("Results for \"\(mainSearchText)\"")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                
                ForEach(0..<5, id: \.self) { i in
                    HStack {
                        Image(systemName: "music.note")
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(6)
                        VStack(alignment: .leading) {
                            Text("Song Result \(i + 1)")
                                .font(.headline)
                            Text("Artist Name")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                    .padding(.vertical)
                
                // --- SECTION B: "Add Missing" Links ---
                // This plugs in your external search views
                VStack(alignment: .leading, spacing: 10) {
                    Text("Don't see what you're looking for?")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Text("Add it to the database:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    
                    // Link 1: Apple Music Albums
                    NavigationLink {
                        SearchAppleMusicAlbumsView(searchText: mainSearchText)
                            .onAppear {
                                mainSearchText = ""
                            }
                            .hideTabBar()
                    } label: {
                        AddSourceRow(icon: "opticaldisc.fill", title: "Search Apple Music Albums", source: "Apple Music")
                    }
                    
                    // Link 2: YouTube Performances
                    NavigationLink {
                        SearchYouTubePerformanceVideosView(searchText: mainSearchText)
                            .onAppear {
                                mainSearchText = ""
                            }
                            .hideTabBar()
                    } label: {
                        AddSourceRow(icon: "music.microphone", title: "Search Performances", source: "YouTube")
                    }
                    
                    // Link 3: YouTube Music Videos
                    NavigationLink {
                        SearchYouTubeMusicVideosView(searchText: mainSearchText)
                            .onAppear {
                                mainSearchText = ""
                            }
                            .hideTabBar()
                    } label: {
                        AddSourceRow(icon: "music.note.tv.fill", title: "Search Music Videos", source: "YouTube")
                    }
                }
                .padding(.bottom, 40)
            }
            .padding(.top)
        }
    }
}

// MARK: - Subview for Music Tab
struct PodcastsSearchContent: View {
    @Binding var mainSearchText: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // --- SECTION A: Local Results (Dummy Data) ---
                // This is where your actual local database results will go later
                if !mainSearchText.isEmpty {
                    Text("Results for \"\(mainSearchText)\"")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                
                ForEach(0..<5, id: \.self) { i in
                    HStack {
                        Image(systemName: "microphone.fill")
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(6)
                        VStack(alignment: .leading) {
                            Text("Podcast Result \(i + 1)")
                                .font(.headline)
                            Text("Host Name")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                    .padding(.vertical)
                
                // --- SECTION B: "Add Missing" Links ---
                // This plugs in your external search views
                VStack(alignment: .leading, spacing: 10) {
                    Text("Don't see what you're looking for?")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Text("Add it to the database:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    
                    NavigationLink {
                        SearchApplePodcastsView(searchText: mainSearchText)
                            .onAppear {
                                mainSearchText = ""
                            }
                            .hideTabBar()
                    } label: {
                        AddSourceRow(icon: "microphone.fill", title: "Search Apple Podcasts", source: "Apple Podcasts")
                    }
                }
                .padding(.bottom, 40)
            }
            .padding(.top)
        }
    }
}

// MARK: - Helper View for the Buttons
struct AddSourceRow: View {
    @Environment(\.colorScheme) var colorScheme

    let icon: String
    let title: String
    let source: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .frame(width: 30)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
            
            Text(title)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
            
            Spacer()
            
            Text(source)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(4)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
        }
        .padding()
        .background(Color.gray.opacity(0.05)) // Subtle background
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    NavigationView {
        SearchView()
    }
}
