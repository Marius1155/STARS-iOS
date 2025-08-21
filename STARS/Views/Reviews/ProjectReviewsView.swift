//
//  ProjectReviewsView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 28.08.2024.
//

import SwiftUI

struct ProjectReviewsView: View {
    /*@Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    @AppStorage("userID") var userID: String = ""
    
    @Binding var project: Project
    
    @State private var reviews: [ProjectReview] = []
    @State private var olderReviewsDict: [String: [ProjectReview]] = [:]
    @State private var showSubreviews: [Bool] = [false]
    @State private var showButton: [Bool] = [true]
    @State private var showNewReviewView: Bool = false
    @State private var isNavigationActive: Bool = false
    @State private var profiles: [String: Profile] = [:]
    
    @State private var showErrorDeletingReviewAlert = false
    @State private var showErrorPostingNewReviewAlert = false
    @State private var selectedStarFilter: Double = 0.0*/
    
    var body: some View {
        /*VStack {
            List {
                VStack(alignment: .leading) {
                    HStack(spacing: 5) {
                        Image(systemName: "opticaldisc.fill")
                        
                        Text(project.title)
                            .bold()
                    }
                    
                    HStack {
                        Image(systemName: project.artist.count == 1 ? "person.fill" : "person.2.fill")
                        
                        if project.artist.isEmpty {
                            Text("Loading artist...") // Placeholder
                        } else {
                            ProjectArtistNameView(project: project)
                        }
                    }
                    
                    HStack{
                        Spacer()
                        Text("•")
                            .bold()
                            .foregroundColor(.black)
                        Text("\(project.reviewsCount) reviews")
                            .italic()
                            .foregroundColor(.black)
                        Text("•")
                            .bold()
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .background{
                        RibbonShape()
                            .fill(Color.accentColor)
                            .frame(height: 30)
                    }
                    .padding(.top, 5)
                }
                
                // Start of reviews display
                ForEach(Array(filteredReviews().enumerated()), id: \.element.id) { index, review in
                    let olderReviews = olderReviewsDict[review.id!] ?? []
                    
                    TabView {
                        VStack(alignment: .leading) {
                            HStack {
                                StarView(stars: review.stars)
                                    .bold()
                                
                                Text(String(format: "%.1f", review.stars))
                                    .bold()
                                
                                Spacer()
                                
                                Text("by:")
                                    .italic()
                                
                                if let profile = profiles[review.user] {
                                    NavigationLink {
                                        ProfileView(id: profile.id!)
                                            .accentColor(Color(hex: profile.accentColorHex) ?? .accentColor)
                                    } label: {
                                        Text(profile.tag)
                                    }
                                    .font(.headline)
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    Text("Unknown user")
                                }
                            }
                            
                            Divider()
                            
                            Text(review.text)
                            
                            if showSubreviews[index] {
                                VStack(alignment: .leading) {
                                    ForEach(0..<review.subreviewsTopics.count, id: \.self) { index in
                                        Divider()
                                        
                                        HStack {
                                            Text(review.subreviewsTopics[index])
                                                .bold()
                                            
                                            StarView(stars: review.subreviewsStars[index])
                                                .bold()
                                            
                                            Text(String(format: "%.1f", review.subreviewsStars[index]))
                                                .bold()
                                        }
                                        
                                        if review.subreviewsTexts[index] != "" {
                                            Text(review.subreviewsTexts[index])
                                                .lineLimit(nil)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                }
                            }
                            
                            HStack{
                                if !review.subreviewsTopics.isEmpty{
                                    Button {
                                        //withAnimation {
                                        showButton[index].toggle()
                                        showSubreviews[index].toggle()
                                        //}
                                    } label: {
                                        Text(showButton[index] ? "Show subreviews" : "Hide subreviews")
                                    }
                                    .font(.footnote)
                                    .buttonStyle(BorderlessButtonStyle())
                                    
                                }
                                
                                Spacer()
                                
                                Text(review.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.footnote)
                            }
                            .padding(.top, 3)
                        }
                        .onAppear {
                            if profiles[review.user] == nil {
                                DispatchQueue.main.async {
                                    dataManager.fetchProfileWithGivenUserID(userID: review.user) { fetchedProfile in
                                        if let fetchedProfile = fetchedProfile {
                                            profiles[review.user] = fetchedProfile
                                        } else {
                                            print("Failed to fetch profile.")
                                        }
                                    }
                                    
                                    dataManager.fetchOlderReviews(for: review) { fetchedReviews in
                                        DispatchQueue.main.async {
                                            olderReviewsDict[review.id!] = fetchedReviews
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill((olderReviewsDict[review.id!]?.isEmpty ?? true) ? Color(UIColor.systemGray6) : Color.accentColor)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal, 2)
                        .listRowSeparator(.hidden)
                        
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if review.user == userID { // Allow delete only for the owner
                                Button(role: .destructive) {
                                    dataManager.deleteProjectReview(reviewID: review.id!, projectID: review.project) { itWorked, message in
                                        if !itWorked {
                                            showErrorDeletingReviewAlert = true
                                            if let message = message {
                                                print(message)
                                            }
                                        }
                                        
                                        else {
                                            DispatchQueue.main.async {
                                                refreshReviews()
                                            }
                                        }
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        
                        ForEach(olderReviews) { review in
                            VStack(alignment: .leading) {
                                HStack {
                                    StarView(stars: review.stars)
                                        .bold()
                                    
                                    Text(String(format: "%.1f", review.stars))
                                        .bold()
                                    
                                    Spacer()
                                    
                                    Text("by:")
                                        .italic()
                                    
                                    if let profile = profiles[review.user] {
                                        NavigationLink {
                                            ProfileView(id: profile.id!)
                                                .accentColor(Color(hex: profile.accentColorHex) ?? .accentColor)
                                        } label: {
                                            Text(profile.tag)
                                        }
                                        .font(.headline)
                                        .buttonStyle(PlainButtonStyle())
                                    } else {
                                        Text("Unknown user")
                                    }
                                }
                                
                                Divider()
                                
                                Text(review.text)
                                
                                if showSubreviews[index] {
                                    VStack(alignment: .leading) {
                                        ForEach(0..<review.subreviewsTopics.count, id: \.self) { index in
                                            Divider()
                                            
                                            HStack {
                                                Text(review.subreviewsTopics[index])
                                                    .bold()
                                                
                                                StarView(stars: review.subreviewsStars[index])
                                                    .bold()
                                                
                                                Text(String(format: "%.1f", review.subreviewsStars[index]))
                                                    .bold()
                                            }
                                            
                                            if review.subreviewsTexts[index] != "" {
                                                Text(review.subreviewsTexts[index])
                                                    .lineLimit(nil)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                        }
                                    }
                                }
                                
                                HStack{
                                    if !review.subreviewsTopics.isEmpty{
                                        Button {
                                            //withAnimation {
                                            showButton[index].toggle()
                                            showSubreviews[index].toggle()
                                            //}
                                        } label: {
                                            Text(showButton[index] ? "Show subreviews" : "Hide subreviews")
                                        }
                                        .font(.footnote)
                                        .buttonStyle(BorderlessButtonStyle())
                                        
                                    }
                                    
                                    Spacer()
                                    
                                    Text(review.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.footnote)
                                }
                                .padding(.top, 3)
                            }
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemGray6))
                                    .shadow(radius: 5)
                            }
                            .padding(.horizontal, 2)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .ignoresSafeArea(.container, edges: .horizontal)
                    .frame(height: 300)
                }
                // End of reviews display
            }
            .listStyle(PlainListStyle())
        }
        .onAppear {
            DispatchQueue.main.async {
                refreshReviews()
            }
        }
        .navigationTitle("Project reviews")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    // Creating filter options for star ratings
                    ForEach([0.0, 1.0, 2.0, 3.0, 4.0, 5.0], id: \.self) { star in
                        Button(action: {
                            selectedStarFilter = star
                        }) {
                            HStack {
                                if star == 0 {
                                    Text("All reviews")
                                }
                                
                                else {
                                    Label("\(Int(star))", systemImage: "star.fill")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button() {
                    showNewReviewView.toggle()
                } label: {
                    Image(systemName: "plus")
                        .bold()
                }
            }
        }
        .sheet(isPresented: $showNewReviewView, content: {
            NewProjectReviewView(project: $project, showErrorPostingNewReviewAlert: $showErrorPostingNewReviewAlert, onReviewAdded: {
                DispatchQueue.main.async {
                    refreshReviews()
                }
            })
            .presentationDetents([.large])
            .interactiveDismissDisabled()
        })
        .alert(isPresented: $showErrorDeletingReviewAlert) {
            Alert(title: Text("Error"), message: Text("Couldn't delete review."), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showErrorPostingNewReviewAlert) {
            Alert(title: Text("Error"), message: Text("Couldn't add review."), dismissButton: .default(Text("OK")))
        }*/
    }
    /*
    private func filteredReviews() -> [ProjectReview] {
        if selectedStarFilter == 0.0 {
            return reviews
        }
        return reviews.filter { $0.stars == selectedStarFilter || $0.stars == selectedStarFilter - 0.5 }
    }
    
    private func refreshReviews() {
        DispatchQueue.main.async {
            dataManager.fetchAProjectsReviewsInfo(project: project) { newProject in
                project = newProject
                
                dataManager.fetchAProjectsReviews(projectID: project.id!) { fetchedReviews in
                    reviews = fetchedReviews
                    
                    showSubreviews = Array(repeating: false, count: reviews.count)
                    showButton = Array(repeating: true, count: reviews.count)
                }
            }
        }
    }*/
}
/*
struct ResizingTabView<Content: View>: View {
    let count: Int
    @ViewBuilder let content: (Int) -> Content

    @State private var currentPage = 0
    @State private var contentHeights: [CGFloat]

    init(count: Int, @ViewBuilder content: @escaping (Int) -> Content) {
        self.count = count
        self.content = content
        self._contentHeights = State(initialValue: Array(repeating: 0, count: count))
    }

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(0..<count, id: \.self) { index in
                    content(index)
                        .background(HeightReader(index: index, heights: $contentHeights))
                        .tag(index)
                }
            }
            .frame(height: contentHeights[safe: currentPage] ?? 100) // fallback height
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .automatic))
            .animation(.easeInOut, value: currentPage)
        }
    }

    struct HeightReader: View {
        let index: Int
        @Binding var heights: [CGFloat]

        var body: some View {
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        update(geo)
                    }
                    .onChange(of: geo.size.height) { _ in
                        update(geo)
                    }
            }
        }

        func update(_ geo: GeometryProxy) {
            DispatchQueue.main.async {
                heights[index] = geo.size.height
            }
        }
    }
}

// Helper to avoid out-of-bounds
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}*/
#Preview {
    /*@Previewable @EnvironmentObject var dataManager: DataManager
    ProjectReviewsView(project: $dataManager.projects.first!)
        .environmentObject(DataManager())*/
}
