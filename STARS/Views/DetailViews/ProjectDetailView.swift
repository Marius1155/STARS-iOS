import SwiftUI
import SDWebImageSwiftUI
import STARSAPI

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
}

struct ProjectDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @State @AppStorage("userID") var userID: String = ""
    
    @State private var showNewReview = false
    @State private var showNewSongReview = false
    @State private var openedSongs: [Bool] = []
    @State private var navTitleColor: Color = .clear
    @State private var hasAlreadyReviewedTheProject = false
    @State private var showErrorPostingNewReviewAlert = false
    @State private var songsHaveLoaded = false
    
    @State private var project: GetProjectDetailQuery.Data.Project?
    
    let projectID: String
    
    var body: some View {
        ScrollView {
            VStack {
                // --- Top colored header with covers carousel ---
                ZStack {
                    Rectangle()
                        .foregroundColor(.accentColor)
                        .frame(height: 120)
                        .shadow(radius: 10)
                    
                    if let covers = project?.covers.compactMap({ $0 }) {
                        TabView {
                            ForEach(covers.sorted(by: { $0.position < $1.position }), id: \.id) { cover in
                                WebImage(url: URL(string: cover.image))
                                    .resizable()
                                    .frame(width: 256, height: 256)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 10)
                                    //.padding(.top, -50)
                            }
                        }
                        .frame(height: 256)
                        .frame(maxWidth: .infinity)
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    }
                }
                /*.background(GeometryReader { geometry in
                    Color.clear.onChange(of: geometry.frame(in: .global).minY) { minY, _ in
                        navTitleColor = minY < -200 ? .primary : .clear
                    }
                })*/
                
                // --- Project title ---
                Text(project?.title ?? "Unknown")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                
                // --- Project artists ---
                if let projectArtists = project?.projectArtists {
                    ProjectArtistNameView(
                        artistsIDs: projectArtists.compactMap { $0.artist.id }, linkToArtists: true
                    )
                    .font(.title3)
                    .padding(.bottom, -1)
                    .multilineTextAlignment(.center)
                }
                
                // --- Release info ---
                HStack {
                    Image(systemName: "opticaldisc.fill").bold()
                    
                    Text(project?.projectType ?? "")
                    
                    Text("•").bold()
                    
                    if let releaseDate = project?.releaseDate,
                       let date = DateFormatter.yyyyMMdd.date(from: releaseDate) {
                        let releaseYear = Calendar.current.component(.year, from: date)
                        Text(String(releaseYear))
                        
                        Text("•").bold()
                    }
                    
                    Text("\(project?.numberOfSongs ?? 0) \(project?.numberOfSongs == 1 ? "track" : "tracks")")
                    
                    Text("•").bold()
                    
                    Text("\(project?.length ?? 0) \(project?.length == 1 ? "minute" : "minutes")")
                }
                .padding(.top, -3)
                
                // --- Rating & reviews box ---
                HStack(spacing: 2) {
                    NavigationLink {
                        if let project = project {
                            //ProjectReviewsView(projectID: project.id)
                        }
                    } label: {
                        HStack(spacing: 0) {
                            if let starAverage = project?.starAverage {
                                StarView(stars: starAverage)
                                    .font(.title3)
                                Text(String(format: "%.1f", starAverage))
                                    .foregroundColor(.black)
                                    .frame(minWidth: 30)
                            } else {
                                ProgressView()
                            }
                        }
                    }
                    .bold()
                    .font(.headline)
                    .frame(minWidth: 60, maxWidth: .infinity, minHeight: 25)
                    .padding(.horizontal, 35)
                    .padding(.vertical, 10)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 5)
                    }
                    
                    Spacer()
                    
                    if let reviewsCount = project?.reviewsCount {
                        Text("(\(reviewsCount) review\(reviewsCount == 1 ? "" : "s"))")
                            .font(.callout)
                            .italic()
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Button {
                        showNewReview.toggle()
                    } label: {
                        Image(systemName: "note.text.badge.plus")
                            .font(.title3)
                            .foregroundColor(hasAlreadyReviewedTheProject ? .gray : .black)
                    }
                    .frame(minWidth: 25, minHeight: 25)
                    .padding(10)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 5)
                    }
                    .disabled(hasAlreadyReviewedTheProject)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.accentColor)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 5)
                .padding(.bottom, 15)
                .padding(.top, 2)
                
                Divider()
                    .padding(.horizontal)
                
                // --- Songs list ---
                if let songs = project?.projectSongs.compactMap({ $0.song }) {
                    ForEach(Array(songs.enumerated()), id: \.element.id) { index, song in
                        VStack {
                            HStack {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        if index < openedSongs.count {
                                            openedSongs[index].toggle()
                                        }
                                    }
                                } label: {
                                    Image(systemName: "arrowtriangle.right.fill")
                                        .bold()
                                        .rotationEffect((index < openedSongs.count && openedSongs[index]) ? .degrees(90) : .degrees(0))
                                        .animation(.easeInOut(duration: 0.2), value: openedSongs[index])
                                }
                                Text("\(index + 1). ")
                                VStack(alignment: .leading) {
                                    Text(song.title)
                                        .truncationMode(.tail)
                                }
                                Spacer()
                                HStack {
                                    Text(String(format: "%.1f", song.starAverage))
                                        .foregroundColor(.black)
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                }
                                .bold()
                                .font(.subheadline)
                                .padding(10)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .shadow(radius: 5)
                                }
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.accentColor)
                                        .shadow(radius: 5)
                                }
                            }
                            if openedSongs.indices.contains(index) && openedSongs[index] {
                                //SongDetailView(song: song)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        Divider()
                            .padding(.horizontal)
                    }
                }
                
                // --- Music Videos horizontal list ---
                if let videos = project?.projectSongs
                    .compactMap({ $0.song.musicVideos })
                    .flatMap({ $0 }) {
                    if !videos.isEmpty {
                        HStack {
                            Text("Music Videos")
                                .font(.title2)
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(videos, id: \.id) { video in
                                    NavigationLink {
                                        //MusicVideoDetailView(musicVideo: video)
                                    } label: {
                                        //MusicVideoPreview(musicVideo: video)
                                           // .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 2)
                    }
                }
            }
            .onAppear {
                fetchProject()
                NotificationCenter.default.post(name: .showTabBar, object: nil)
                dataManager.shouldShowTabBar = true
            }
        }
        .navigationTitle(project?.title ?? "Unknown")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(project?.title ?? "")
                    .font(.headline)
                    .foregroundColor(navTitleColor)
            }
        }
        /*.sheet(isPresented: $showNewReview) {
            if let project = project {
                NewProjectReviewView(
                    projectID: project.id,
                    showErrorPostingNewReviewAlert: $showErrorPostingNewReviewAlert
                ) {
                    fetchProject()
                }
                .presentationDetents([.large])
                .interactiveDismissDisabled()
            }
        }*/
        .alert(isPresented: $showErrorPostingNewReviewAlert) {
            Alert(title: Text("Error"),
                  message: Text("Couldn't add review."),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    // MARK: - Apollo fetch
    private func fetchProject() {
        Network.shared.apollo.fetch(query: STARSAPI.GetProjectDetailQuery(projectId: String(projectID))) { result in
            switch result {
            case .success(let graphQLResult):
                if let fetched = graphQLResult.data?.projects.first {
                    project = fetched
                    openedSongs = Array(repeating: false, count: fetched.projectSongs.count)
                    songsHaveLoaded = true
                }
            case .failure(let error):
                print("Error loading project: \(error)")
            }
        }
    }
}

#Preview {
    NavigationView {
        ProjectDetailView(projectID: "1")
    }
}
