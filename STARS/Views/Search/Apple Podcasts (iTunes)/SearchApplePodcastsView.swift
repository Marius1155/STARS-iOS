//
//  SearchApplePodcastsView.swift
//  STARS
//
//  Created by Marius Gabriel Budai on 29.12.2025.
//

import SwiftUI
import STARSAPI

struct SearchApplePodcastsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @State private var podcasts: [STARSAPI.SearchApplePodcastsQuery.Data.SearchItunesPodcast] = []
    @State var searchText: String
    
    @State private var podcastToAddId: String = ""
    @State private var podcastToAddTitle: String = ""
    
    @State private var askForConfirmation: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var alertMessage: String? = nil
    @State private var isAddingPodcast: Bool = false
    
    var body: some View {
        VStack(spacing: 10) {
            if searchText.isEmpty && podcasts.isEmpty {
                emptyStatePlaceholder
            }
            else if !searchText.isEmpty && podcasts.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
            else {
                ScrollView {
                    VStack {
                        ForEach(podcasts, id: \.id) {podcast in
                            Button {
                                podcastToAddId = podcast.id
                                podcastToAddTitle = podcast.title
                                askForConfirmation = true
                            } label: {
                                PodcastListPreview(id: podcast.id, title: podcast.title, coverUrl: podcast.imageUrl, host: podcast.host)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .overlay {
            if isAddingPodcast {
                ZStack {
                    // Dimmed background
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    // Loading Box
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.primary)
                        
                        VStack(spacing: 4) {
                            Text("Adding Podcast...")
                                .font(.headline)
                            
                            Text("Please don't leave this page")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(24)
                    .background(.regularMaterial) // Glass effect
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 10)
                }
            }
        }
        .disabled(isAddingPodcast)
        .searchable(text: $searchText, prompt: "Search podcasts")
        .task(id: searchText) {
            if searchText.isEmpty {
                podcasts.removeAll()
                return
            }
            
            // 1. Debounce: Wait 250ms. If a new key is pressed, this task will be cancelled and a new one started.
            do {
                try await Task.sleep(for: .milliseconds(250))
            } catch {
                return // Task was cancelled (new input received)
            }
            
            // 2. Perform the API call with the debounced text
            fetchPodcasts(term: searchText)
        }
        .alert(alertMessage ?? "", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) { alertMessage = nil }
        }
        .alert("Podcast added successfully!", isPresented: $showSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("The podcast has been successfully added to the STARS database.")
        }
        .alert("Add \(podcastToAddTitle) to the STARS database?", isPresented: $askForConfirmation) {
            Button("No") { }
                .foregroundStyle(.gray)
            
            Button("Yes") {
                isAddingPodcast = true
                submitPodcast(id: podcastToAddId)
            }
            .foregroundStyle(colorScheme == .dark ? .white : .black)
        }
        .navigationTitle("Search Podcasts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Search Podcasts")
                    .font(.headline)
                    .foregroundColor(.clear)
            }
        }
    }
    
    @ViewBuilder
        var emptyStatePlaceholder: some View {
            VStack(spacing: 24) {
                Spacer()
                Spacer()
                
                Image("ApplePodcastsIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                    .shadow(color: colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 8) {
                    Text("Search Apple Podcasts")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                    
                    Text("Find podcasts to add to the database.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                Spacer()
                Spacer()
            }
        }
    
    func fetchPodcasts(term: String) {
        let query = STARSAPI.SearchApplePodcastsQuery(term: term)
        
        Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
            switch result {
            case .success(let graphQLResult):
                if let fetchedPodcasts = graphQLResult.data?.searchItunesPodcasts {
                    DispatchQueue.main.async {
                        self.podcasts = fetchedPodcasts
                    }
                } else if let errors = graphQLResult.errors {
                    print("GraphQL errors:", errors)
                }
            case .failure(let error):
                print("Error fetching apple podcasts: \(error)")
            }
        }
    }
    
    func submitPodcast(id: String) {
        Network.shared.apollo.perform(mutation: STARSAPI.AddPodcastMutation(id: id)) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let graphQLResult):
                    if graphQLResult.data?.importPodcastFromItunes.id != nil {
                        self.isAddingPodcast = false
                        self.showSuccessAlert = true
                    } else if let errors = graphQLResult.errors {
                        self.isAddingPodcast = false
                        self.alertMessage = "GraphQL Error: \(errors.map { $0.message ?? "unknown" }.joined(separator: ", "))"
                    }
                case .failure(let error):
                    self.alertMessage = "Network Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        SearchApplePodcastsView(searchText: "")
    }
}
