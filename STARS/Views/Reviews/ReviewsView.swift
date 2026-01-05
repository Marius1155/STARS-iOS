//
//  ProjectReviewsView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 28.08.2024.
//

import Foundation
import SwiftUI
import Combine
import STARSAPI
import Apollo
import SDWebImageSwiftUI
import STARSAPI


// This ViewModel will be the "brain" for your ConversationView
/*
@MainActor
class ReviewsViewModel: ObservableObject {
    private var dataManager: DataManager?
    // MARK: - Published Properties
    @Published var reviews: [ReviewFragment] = []
    //@Published var project:
    
    // MARK: - Properties
    @Published var objectID: String
    @Published var objectType: String
    
    @AppStorage("userID") var userID: String = ""
    
    @Published var pageSize = 30
    private var nextCursor: String? = nil
    @Published var hasNextPageOlder = false
    @Published var fetchingDesc = true
    @Published var filteringStars: Float = 0
    
    @Published var primaryBgColor: Color = .gray
    @Published var primaryTextColor: Color = .white
    @Published var primaryGrayTextColor: Color = Color(.systemGray3)
    @Published var secondaryBgColor: Color = .gray
    @Published var secondaryTextColor: Color = .white
    @Published var secondaryGrayTextColor: Color = Color(.systemGray3)
    
    @Published var isLoaded: Bool = false
        
    init(objectID: String, objectType: String) {
        self.objectID = objectID
        self.objectType = objectType
    }
    
    func setDataManager(_ dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    // MARK: - Public Methods
    func fetchInitialData() {
        nextCursor = nil
        hasNextPageOlder = false
        
        if fetchingDesc {
            if filteringStars == 0 {
                let query = STARSAPI.GetReviewsOfAnObjectDescQuery(objectId: Int(self.objectID) ?? 0, contentType: self.objectType, reviewsFirst: .some(self.pageSize), reviewsAfter: nil)
                
                Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
                    switch result {
                    case .success(let graphQLResult):
                        if let rawReviews = graphQLResult.data?.reviews {
                            let fetchedReviews = rawReviews.edges.compactMap{ $0.node.fragments.reviewFragment }
                            
                            if let project = fetchedReviews.first?.contentObject.asProject {
                                if let node = project.covers.edges.first?.node {
                                    self.primaryBgColor = Color(hex: node.primaryColor) ?? .gray
                                    self.primaryTextColor = self.primaryBgColor.prefersWhiteText() ? .white : .black
                                    self.primaryGrayTextColor = self.primaryBgColor.secondaryTextGray()
                                    self.secondaryBgColor = Color(hex: node.secondaryColor) ?? .gray
                                    self.secondaryTextColor = self.secondaryBgColor.prefersWhiteText() ? .white : .black
                                    self.secondaryGrayTextColor = self.secondaryBgColor.secondaryTextGray()
                                    
                                    self.dataManager?.accentColor = self.secondaryBgColor
                                }
                            }
                            
                            self.reviews = fetchedReviews
                            self.isLoaded = true
                            
                            self.nextCursor = rawReviews.pageInfo.startCursor
                            
                            self.hasNextPageOlder = rawReviews.pageInfo.hasPreviousPage
                            
                        }
                    case .failure(let error):
                        print("Error fetching reviews: \(error)")
                    }
                }
            }
            
            else {
                let query = STARSAPI.GetReviewsOfAnObjectDescWithStarFilterQuery(objectId: Int(self.objectID) ?? 0, contentType: self.objectType, reviewsFirst: .some(self.pageSize), reviewsAfter: nil, starsFilterWhole: String(self.filteringStars), starsFilterPointFive: String(self.filteringStars - 0.5))
                
                Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
                    switch result {
                    case .success(let graphQLResult):
                        if let rawReviews = graphQLResult.data?.reviews {
                            let fetchedReviews = rawReviews.edges.compactMap{ $0.node.fragments.reviewFragment }
                            
                            if let project = fetchedReviews.first?.contentObject.asProject {
                                if let node = project.covers.edges.first?.node {
                                    self.primaryBgColor = Color(hex: node.primaryColor) ?? .gray
                                    self.primaryTextColor = self.primaryBgColor.prefersWhiteText() ? .white : .black
                                    self.primaryGrayTextColor = self.primaryBgColor.secondaryTextGray()
                                    self.secondaryBgColor = Color(hex: node.secondaryColor) ?? .gray
                                    self.secondaryTextColor = self.secondaryBgColor.prefersWhiteText() ? .white : .black
                                    self.secondaryGrayTextColor = self.secondaryBgColor.secondaryTextGray()
                                    
                                    self.dataManager?.accentColor = self.secondaryBgColor
                                }
                            }
                            
                            self.reviews = fetchedReviews
                            self.isLoaded = true
                            
                            self.nextCursor = rawReviews.pageInfo.startCursor
                            
                            self.hasNextPageOlder = rawReviews.pageInfo.hasPreviousPage
                            
                        }
                    case .failure(let error):
                        print("Error fetching reviews: \(error)")
                    }
                }
            }
        }
        
        else {
            if filteringStars == 0 {
                let query = STARSAPI.GetReviewsOfAnObjectAscQuery(objectId: Int(self.objectID) ?? 0, contentType: self.objectType, reviewsFirst: .some(self.pageSize), reviewsAfter: nil)
                
                Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
                    switch result {
                    case .success(let graphQLResult):
                        if let rawReviews = graphQLResult.data?.reviews {
                            let fetchedReviews = rawReviews.edges.compactMap{ $0.node.fragments.reviewFragment }
                            
                            if let project = fetchedReviews.first?.contentObject.asProject {
                                if let node = project.covers.edges.first?.node {
                                    self.primaryBgColor = Color(hex: node.primaryColor) ?? .gray
                                    self.primaryTextColor = self.primaryBgColor.prefersWhiteText() ? .white : .black
                                    self.primaryGrayTextColor = self.primaryBgColor.secondaryTextGray()
                                    self.secondaryBgColor = Color(hex: node.secondaryColor) ?? .gray
                                    self.secondaryTextColor = self.secondaryBgColor.prefersWhiteText() ? .white : .black
                                    self.secondaryGrayTextColor = self.secondaryBgColor.secondaryTextGray()
                                    
                                    self.dataManager?.accentColor = self.secondaryBgColor
                                }
                            }
                            
                            self.reviews = fetchedReviews
                            self.isLoaded = true
                            
                            self.nextCursor = rawReviews.pageInfo.startCursor
                            
                            self.hasNextPageOlder = rawReviews.pageInfo.hasPreviousPage
                            
                        }
                    case .failure(let error):
                        print("Error fetching reviews: \(error)")
                    }
                }
            }
            
            else {
                let query = STARSAPI.GetReviewsOfAnObjectAscWithStarFilterQuery(objectId: Int(self.objectID) ?? 0, contentType: self.objectType, reviewsFirst: .some(self.pageSize), reviewsAfter: nil, starsFilterWhole: String(self.filteringStars), starsFilterPointFive: String(self.filteringStars - 0.5))
                
                Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
                    switch result {
                    case .success(let graphQLResult):
                        if let rawReviews = graphQLResult.data?.reviews {
                            let fetchedReviews = rawReviews.edges.compactMap{ $0.node.fragments.reviewFragment }
                            
                            if let project = fetchedReviews.first?.contentObject.asProject {
                                if let node = project.covers.edges.first?.node {
                                    self.primaryBgColor = Color(hex: node.primaryColor) ?? .gray
                                    self.primaryTextColor = self.primaryBgColor.prefersWhiteText() ? .white : .black
                                    self.primaryGrayTextColor = self.primaryBgColor.secondaryTextGray()
                                    self.secondaryBgColor = Color(hex: node.secondaryColor) ?? .gray
                                    self.secondaryTextColor = self.secondaryBgColor.prefersWhiteText() ? .white : .black
                                    self.secondaryGrayTextColor = self.secondaryBgColor.secondaryTextGray()
                                    
                                    self.dataManager?.accentColor = self.secondaryBgColor
                                }
                            }
                            
                            self.reviews = fetchedReviews
                            self.isLoaded = true
                            
                            self.nextCursor = rawReviews.pageInfo.startCursor
                            
                            self.hasNextPageOlder = rawReviews.pageInfo.hasPreviousPage
                            
                        }
                    case .failure(let error):
                        print("Error fetching reviews: \(error)")
                    }
                }
            }
        }
    }
    
    func loadOlderReviews() {
        guard let nextCursor = self.nextCursor else { return }
        
        if fetchingDesc {
            if filteringStars == 0 {
                let query = STARSAPI.GetReviewsOfAnObjectDescQuery(objectId: Int(self.objectID) ?? 0, contentType: self.objectType, reviewsFirst: .some(self.pageSize), reviewsAfter: .some(self.nextCursor!))
                
                
                Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
                    switch result {
                    case .success(let graphQLResult):
                        if let rawReviews = graphQLResult.data?.reviews {
                            let newReviews = rawReviews.edges.compactMap{ $0.node.fragments.reviewFragment }
                            
                            DispatchQueue.main.async {
                                withAnimation(.bouncy()) {
                                    self.reviews += newReviews
                                }
                                
                                self.nextCursor = rawReviews.pageInfo.startCursor
                                
                                self.hasNextPageOlder = rawReviews.pageInfo.hasPreviousPage
                            }
                        }
                        
                    case .failure(let error):
                        print("Error loading older reviews: \(error)")
                    }
                }
            }
            
            else {
                let query = STARSAPI.GetReviewsOfAnObjectDescWithStarFilterQuery(objectId: Int(self.objectID) ?? 0, contentType: self.objectType, reviewsFirst: .some(self.pageSize), reviewsAfter: .some(self.nextCursor!), starsFilterWhole: String(self.filteringStars), starsFilterPointFive: String(self.filteringStars - 0.5))
                
                
                Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
                    switch result {
                    case .success(let graphQLResult):
                        if let rawReviews = graphQLResult.data?.reviews {
                            let newReviews = rawReviews.edges.compactMap{ $0.node.fragments.reviewFragment }
                            
                            DispatchQueue.main.async {
                                withAnimation(.bouncy()) {
                                    self.reviews += newReviews
                                }
                                
                                self.nextCursor = rawReviews.pageInfo.startCursor
                                
                                self.hasNextPageOlder = rawReviews.pageInfo.hasPreviousPage
                            }
                        }
                        
                    case .failure(let error):
                        print("Error loading older reviews: \(error)")
                    }
                }
            }
        }
        
        else {
            if filteringStars == 0 {
                let query = STARSAPI.GetReviewsOfAnObjectAscQuery(objectId: Int(self.objectID) ?? 0, contentType: self.objectType, reviewsFirst: .some(self.pageSize), reviewsAfter: .some(self.nextCursor!))
                
                
                Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
                    switch result {
                    case .success(let graphQLResult):
                        if let rawReviews = graphQLResult.data?.reviews {
                            let newReviews = rawReviews.edges.compactMap{ $0.node.fragments.reviewFragment }
                            
                            DispatchQueue.main.async {
                                withAnimation(.bouncy()) {
                                    self.reviews += newReviews
                                }
                                
                                self.nextCursor = rawReviews.pageInfo.startCursor
                                
                                self.hasNextPageOlder = rawReviews.pageInfo.hasPreviousPage
                            }
                        }
                        
                    case .failure(let error):
                        print("Error loading older reviews: \(error)")
                    }
                }
            }
            
            else {
                let query = STARSAPI.GetReviewsOfAnObjectAscWithStarFilterQuery(objectId: Int(self.objectID) ?? 0, contentType: self.objectType, reviewsFirst: .some(self.pageSize), reviewsAfter: .some(self.nextCursor!), starsFilterWhole: String(self.filteringStars), starsFilterPointFive: String(self.filteringStars - 0.5))
                
                
                Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
                    switch result {
                    case .success(let graphQLResult):
                        if let rawReviews = graphQLResult.data?.reviews {
                            let newReviews = rawReviews.edges.compactMap{ $0.node.fragments.reviewFragment }
                            
                            DispatchQueue.main.async {
                                withAnimation(.bouncy()) {
                                    self.reviews += newReviews
                                }
                                
                                self.nextCursor = rawReviews.pageInfo.startCursor
                                
                                self.hasNextPageOlder = rawReviews.pageInfo.hasPreviousPage
                            }
                        }
                        
                    case .failure(let error):
                        print("Error loading older reviews: \(error)")
                    }
                }
            }
        }
    }
    
    func likeReview(reviewID: String) {
        let mutation = STARSAPI.LikeDislikeReviewMutation(reviewID: reviewID, action: GraphQLEnum(LikeAction.like))
        Network.shared.apollo.perform(mutation: mutation) { result in
            switch result {
            case .success(let graphQLResult):
                if let errors = graphQLResult.errors {
                    print("GraphQL Error: \(errors)")
                }
            case .failure(let error):
                print("Network Error: \(error)")
            }
        }
    }
    
    func dislikeReview(reviewID: String) {
        let mutation = STARSAPI.LikeDislikeReviewMutation(reviewID: reviewID, action: GraphQLEnum(LikeAction.dislike))
        Network.shared.apollo.perform(mutation: mutation) { result in
            switch result {
            case .success(let graphQLResult):
                if let errors = graphQLResult.errors {
                    print("GraphQL Error: \(errors)")
                }
            case .failure(let error):
                print("Network Error: \(error)")
            }
        }
    }
}

struct ReviewsView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject private var viewModel: ReviewsViewModel
    
    @AppStorage("userID") var userID: String = ""
    
    @State private var showNewProjectReviewView: Bool = false
    var projectTitle: String?
    var projectArtistsIDs: [String]?
    
    @State private var showErrorDeletingReviewAlert = false
    @State private var showErrorPostingNewReviewAlert = false
    
    @State private var isLiked: [Bool] = []
    @State private var isDisliked: [Bool] = []
    
    @State private var likesCount: [Int] = []
    @State private var dislikesCount: [Int] = []
    @State private var commentsCount: [Int] = []
    
    init(objectID: String, objectType: String, projectTitle: String? = nil, projectArtists: [(id: String, name: String, position: Int)]? = nil) {
        _viewModel = StateObject(wrappedValue: ReviewsViewModel(objectID: objectID, objectType: objectType))
        
        self.projectTitle = projectTitle
        self.projectArtistsIDs = projectArtistsIDs
    }
    
    var body: some View {
        VStack {
            if viewModel.reviews.isEmpty && viewModel.isLoaded {
                VStack {
                    Spacer()
                    
                    Text("No reviews")
                    
                    Spacer()
                }
            }
            
            else {
                ScrollView {
                    LazyVStack {
                        ForEach(Array(viewModel.reviews.enumerated()), id: \.element.id) { index, review in
                            ZStack {
                                if review.isRereview {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(viewModel.secondaryBgColor)
                                        .offset(x: 10, y: 5)
                                        .shadow(radius: 3)
                                }
                                
                                VStack(alignment: .leading) {
                                    if let project = viewModel.reviews.first?.contentObject.asProject {
                                        if let node = project.covers.edges.first?.node {
                                            HStack {
                                                NavigationLink {
                                                    ProjectDetailView(projectID: project.id)
                                                } label: {
                                                    WebImage(url: URL(string: node.image))
                                                        .resizable()
                                                        .frame(width: 128, height: 128)
                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                                        .shadow(radius: 3)
                                                }
                                                
                                                Spacer()
                                                
                                                VStack {
                                                    NavigationLink {
                                                        ProfileView(id: review.user.id)
                                                    } label: {
                                                        HStack(spacing: 0) {
                                                            Spacer()
                                                            
                                                            if let profilePicture = review.user.profile.profilePicture {
                                                                WebImage(url: URL(string: profilePicture))
                                                                    .resizable()
                                                                    .frame(width: 32, height: 32)
                                                                    .clipShape(Circle())
                                                                    .padding(.horizontal, 5)
                                                            }
                                                            else {
                                                                Image(systemName: "person.crop.circle")
                                                                    .frame(width: 32, height: 32)
                                                                    .clipShape(Circle())
                                                                    .foregroundStyle(viewModel.primaryTextColor)
                                                            }
                                                            
                                                            Text("@\(review.user.username)")
                                                                .padding(.trailing, 5)
                                                                .foregroundStyle(viewModel.primaryTextColor)
                                                            
                                                            Spacer()
                                                        }
                                                        .padding(.vertical, 5)
                                                        .background {
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .foregroundStyle(viewModel.primaryBgColor)
                                                                .shadow(radius: 3)
                                                        }
                                                    }
                                                    
                                                    Text(review.isRereview ? "rereviewed" : "reviewed")
                                                        .font(.footnote)
                                                        .padding(.top, -3)
                                                        .foregroundStyle(viewModel.secondaryGrayTextColor)
                                                    
                                                    NavigationLink {
                                                        ProjectDetailView(projectID: project.id)
                                                    } label: {
                                                        VStack {
                                                            HStack(spacing: 1) {
                                                                Image(systemName: "opticaldisc.fill")
                                                                    .foregroundStyle(viewModel.secondaryTextColor)
                                                                
                                                                Text(project.title)
                                                                    .bold()
                                                                    .lineLimit(1)
                                                                    .foregroundStyle(viewModel.secondaryTextColor)
                                                            }
                                                            
                                                            Text("by")
                                                                .font(.footnote)
                                                                .padding(.top, -7)
                                                                .foregroundStyle(viewModel.secondaryGrayTextColor)
                                                            
                                                            ProjectArtistNameView(artistsIDs: project.projectArtists.edges
                                                                .compactMap { $0.node }
                                                                .sorted { $0.position < $1.position }
                                                                .compactMap { $0.artist.id })
                                                            .foregroundStyle(viewModel.secondaryTextColor)
                                                        }
                                                    }
                                                }
                                                
                                                Spacer()
                                            }
                                            .padding(5)
                                            .background {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundStyle(viewModel.secondaryBgColor)
                                                    .shadow(radius: 3)
                                            }
                                        }
                                    }
                                    
                                    HStack {
                                        NavigationLink {
                                            ReviewDetailView(reviewUserID: review.user.id, contentType: viewModel.objectType, objectID: viewModel.objectID)
                                        } label: {
                                            HStack {
                                                StarView(stars: decimalStringToDouble(review.stars) ?? 0)
                                                    .bold()
                                                
                                                Text(String(format: "%.1f", decimalStringToDouble(review.stars) ?? 0))
                                                    .bold()
                                                    .foregroundStyle(viewModel.primaryTextColor)
                                                
                                                Spacer()
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        Spacer()
                                    }
                                    .padding(.top, 5)
                                    .padding(.bottom, -5)
                                    
                                    Divider()
                                        .foregroundStyle(viewModel.primaryTextColor)
                                    
                                    NavigationLink {
                                        ReviewDetailView(reviewUserID: review.user.id, contentType: viewModel.objectType, objectID: viewModel.objectID)
                                    } label: {
                                        VStack(alignment: .leading) {
                                            Text(review.title)
                                                .bold()
                                                .foregroundStyle(viewModel.primaryTextColor)
                                            
                                            Text(review.text)
                                                .lineLimit(5)
                                                .padding(.vertical, 1)
                                                .foregroundStyle(viewModel.primaryTextColor)
                                            
                                            Text("See full review...")
                                                .font(.footnote)
                                                .foregroundStyle(viewModel.primaryGrayTextColor)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Divider()
                                        .foregroundStyle(viewModel.primaryTextColor)
                                    
                                    HStack{
                                        Button {
                                            likeReview(reviewID: review.id)
                                            
                                            if !isLiked[index] {
                                                isLiked[index] = true
                                                likesCount[index] += 1
                                                
                                                if isDisliked[index] {
                                                    isDisliked[index] = false
                                                    dislikesCount[index] -= 1
                                                }
                                            }
                                            
                                            else {
                                                isLiked[index] = false
                                                likesCount[index] -= 1
                                            }
                                        } label: {
                                            Image(systemName: "hand.thumbsup")
                                                .symbolVariant(isLiked[index] ? .fill : .none)
                                                .foregroundStyle(viewModel.primaryTextColor)
                                        }
                                        
                                        Text(formatNumber(likesCount[index]))
                                            .font(.caption)
                                            .padding(.trailing)
                                            .foregroundStyle(viewModel.primaryTextColor)
                                        
                                        Button {
                                            dislikeReview(reviewID: review.id)
                                            
                                            if !isDisliked[index] {
                                                isDisliked[index] = true
                                                dislikesCount[index] += 1
                                                
                                                if isLiked[index] {
                                                    isLiked[index] = false
                                                    likesCount[index] -= 1
                                                }
                                            }
                                            
                                            else {
                                                isDisliked[index] = false
                                                dislikesCount[index] -= 1
                                            }
                                        } label: {
                                            Image(systemName: "hand.thumbsdown")
                                                .symbolVariant(isDisliked[index] ? .fill : .none)
                                                .foregroundStyle(viewModel.primaryTextColor)
                                        }
                                        
                                        Text(formatNumber(dislikesCount[index]))
                                            .font(.caption)
                                            .padding(.trailing)
                                            .foregroundStyle(viewModel.primaryTextColor)
                                        
                                        NavigationLink {
                                            ReviewDetailView(reviewUserID: review.user.id, contentType: viewModel.objectType, objectID: viewModel.objectID, typingNewComment: true)
                                        } label: {
                                            Image(systemName: "message")
                                                .foregroundStyle(viewModel.primaryTextColor)
                                        }
                                        
                                        Text(formatNumber(commentsCount[index]))
                                            .font(.caption)
                                            .padding(.trailing)
                                            .foregroundStyle(viewModel.primaryTextColor)
                                        
                                        NavigationLink {
                                            ReviewDetailView(reviewUserID: review.user.id, contentType: viewModel.objectType, objectID: viewModel.objectID)
                                        } label: {
                                            HStack {
                                                Spacer()
                                                
                                                Text((date(from: review.dateCreated) ?? Foundation.Date()).formatted(date: .abbreviated, time: .omitted))
                                                    .font(.footnote)
                                                    .foregroundStyle(viewModel.primaryGrayTextColor)
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle()).buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(viewModel.primaryBgColor)
                                }
                                .shadow(radius: 3)
                                .onAppear {
                                    isLiked[index] = review.likedByCurrentUser
                                    isDisliked[index] = review.dislikedByCurrentUser
                                    likesCount[index] = review.likesCount
                                    dislikesCount[index] = review.dislikesCount
                                    commentsCount[index] = review.commentsCount
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, review.isRereview ? 5 : 0)
                            
                            /*.swipeActions(edge: .trailing, allowsFullSwipe: true) {
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
                             }*/
                        }
                        .ignoresSafeArea(.container, edges: .horizontal)
                        
                        if viewModel.hasNextPageOlder {
                            ProgressView()
                                .onAppear {
                                    viewModel.loadOlderReviews()
                                }
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.setDataManager(DataManager.shared)
            
            viewModel.fetchInitialData()
            
            isLiked = Array(repeating: false, count: viewModel.pageSize)
            isDisliked = Array(repeating: false, count: viewModel.pageSize)
            
            likesCount = Array(repeating: 0, count: viewModel.pageSize)
            dislikesCount = Array(repeating: 0, count: viewModel.pageSize)
            commentsCount = Array(repeating: 0, count: viewModel.pageSize)
        }
        .navigationTitle("Reviews")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach([0.0, 1.0, 2.0, 3.0, 4.0, 5.0], id: \.self) { star in
                        Button(action: {
                            if viewModel.filteringStars != Float(star) {
                                viewModel.filteringStars = Float(star)
                                viewModel.fetchInitialData()
                            }
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
                    showNewProjectReviewView.toggle()
                } label: {
                    Image(systemName: "plus")
                        .bold()
                }
            }
        }
        .sheet(isPresented: $showNewProjectReviewView) {
            if let projectTitle = projectTitle, let projectArtistsIDs = projectArtistsIDs {
                NewProjectReviewView(
                    projectID: viewModel.objectID,
                    projectTitle: projectTitle,
                    projectArtistsIDs: projectArtistsIDs,
                    showErrorPostingNewReviewAlert: $showErrorPostingNewReviewAlert
                ) {
                    viewModel.fetchInitialData()
                    showNewProjectReviewView = false
                }
                .presentationDetents([.large])
                .interactiveDismissDisabled()
            }
            else {
                Text("Error")
            }
        }
        .alert(isPresented: $showErrorDeletingReviewAlert) {
            Alert(title: Text("Error"), message: Text("Couldn't delete review."), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showErrorPostingNewReviewAlert) {
            Alert(title: Text("Error"), message: Text("Couldn't add review."), dismissButton: .default(Text("OK")))
        }
    }
    
    func likeReview(reviewID: String) {
        viewModel.likeReview(reviewID: reviewID)
    }
    
    func dislikeReview(reviewID: String) {
        viewModel.dislikeReview(reviewID: reviewID)
    }
    
    func decimalStringToDouble(_ value: String) -> Double? {
        if let decimal = Decimal(string: value) {
            return NSDecimalNumber(decimal: decimal).doubleValue
        }
        return nil
    }
    
    private func date(from string: String) -> Foundation.Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: string)
    }
    
    func formatNumber(_ number: Int) -> String {
        if number < 1000 {
            return "\(number)"
        } else if number < 1_000_000 {
            let thousands = Double(number) / 1000.0
            if number % 1000 == 0 {
                return "\(Int(thousands))k"
            } else {
                return String(format: "%.1fk", thousands)
            }
        } else {
            let millions = Double(number) / 1_000_000.0
            if number % 1_000_000 == 0 {
                return "\(Int(millions))M"
            } else {
                return String(format: "%.1fM", millions)
            }
        }
    }
}

/*extension View {
    @ViewBuilder
    func applyGlassEffectIfAvailable(color: String) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(
                .regular
                    .tint((Color(hex: color) ?? .gray)),
                in: .rect(cornerRadius: 10)
            )
        } else {
            self.background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color(hex: color) ?? .gray)
            }
        }
    }
}*/


/*struct ResizingTabView<Content: View>: View {
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
//#Preview {
    /*@Previewable
    ProjectReviewsView(project: $dataManager.projects.first!)
         */
//}

*/
