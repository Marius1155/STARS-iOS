//
//  ReviewDetailView.swift
//  STARS
//
//  Created by Marius Gabriel Budai on 18.09.2025.
//

import SwiftUI
import STARSAPI
import SDWebImageSwiftUI

@MainActor
class ReviewDetailViewModel: ObservableObject {
    // MARK: - Properties
    private var dataManager: DataManager?
    @Published var reviewUserID: String
    @Published var contentType: String
    @Published var objectID: String
    @Published var reviews: [ReviewFragment] = []
    @Published var comments: [CommentFragment] = []
    @Published var replies: [CommentFragment] = []
    @AppStorage("userID") var userID: String = ""
    
    @Published var pageSize = 10
    private var commentsNextCursor: String? = nil
    @Published var commentsHasNextPageOlder = false
    
    @Published var fetchingMostPopular = true
    
    @Published var replyPageSize = 10
    private var repliesNextCursor: String? = nil
    @Published var repliesHasNextPageOlder = false
    
    @Published var showingRepliesForCommentID: String? = nil
    
    @Published var primaryBgColor: Color = .gray
    @Published var primaryTextColor: Color = .white
    @Published var primaryGrayTextColor: Color = Color(.systemGray3)
    @Published var secondaryBgColor: Color = .gray
    @Published var secondaryTextColor: Color = .white
    @Published var secondaryGrayTextColor: Color = Color(.systemGray3)
    
    @Published var commentsLikesCounts: [Int] = []
    @Published var commentsDislikesCounts: [Int] = []
    @Published var commentsAreLiked: [Bool] = []
    @Published var commentsAreDisliked: [Bool] = []
    @Published var commentsNumberOfReplies: [Int] = []
    
    @Published var repliesLikesCounts: [Int] = []
    @Published var repliesDislikesCounts: [Int] = []
    @Published var repliesAreLiked: [Bool] = []
    @Published var repliesAreDisliked: [Bool] = []
    
    @Published var isLoaded: Bool = false
    
    init(reviewUserID: String, contentType: String, objectID: String) {
        self.reviewUserID = reviewUserID
        self.contentType = contentType
        self.objectID = objectID
    }
    
    func setDataManager(_ dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    // MARK: - Public Methods
    func fetchInitialData() {
        let query = STARSAPI.GetUsersReviewsOfACertainObjectQuery(objectId: Int(self.objectID) ?? 0, contentType: self.contentType, userID: self.reviewUserID)
        
        Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
            switch result {
            case .success(let graphQLResult):
                if let rawReviews = graphQLResult.data?.users.edges.first?.node.reviews {
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
                }
            case .failure(let error):
                print("Error fetching reviews: \(error)")
            }
        }
    }
    
    func fetchInitialComments(reviewID: String) {
        print("fetched Initial Comments")
        commentsNextCursor = nil
        commentsHasNextPageOlder = false
        
        if fetchingMostPopular {
            let query = STARSAPI.GetAReviewsCommentsMostPopularQuery(reviewID: reviewID, commentsFirst: .some(self.pageSize), commentsAfter: nil)
            
            Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
                switch result {
                case .success(let graphQLResult):
                    if let rawComments = graphQLResult.data?.reviews.edges.first?.node.comments {
                        let fetchedComments = rawComments.edges.compactMap{ $0.node.fragments.commentFragment }
                        
                        self.commentsLikesCounts = Array(repeating: 0, count: fetchedComments.count)
                        self.commentsDislikesCounts = Array(repeating: 0, count: fetchedComments.count)
                        self.commentsAreLiked = Array(repeating: false, count: fetchedComments.count)
                        self.commentsAreDisliked = Array(repeating: false, count: fetchedComments.count)
                        self.commentsNumberOfReplies = Array(repeating: 0, count: fetchedComments.count)

                        self.comments = fetchedComments
                        
                        self.commentsNextCursor = rawComments.pageInfo.startCursor
                        
                        self.commentsHasNextPageOlder = rawComments.pageInfo.hasPreviousPage
                        
                        print("has comments previous page: \(rawComments.pageInfo.hasPreviousPage)")
                        print("has comments next page: \(rawComments.pageInfo.hasNextPage)")
                        
                    }
                case .failure(let error):
                    print("Error fetching comments: \(error)")
                }
            }
        }
        
        else {
            let query = STARSAPI.GetAReviewsCommentsLatestQuery(reviewID: reviewID, commentsFirst: .some(self.pageSize), commentsAfter: nil)
            
            Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
                switch result {
                case .success(let graphQLResult):
                    if let rawComments = graphQLResult.data?.reviews.edges.first?.node.comments {
                        let fetchedComments = rawComments.edges.compactMap{ $0.node.fragments.commentFragment }
                        
                        self.commentsLikesCounts = Array(repeating: 0, count: fetchedComments.count)
                        self.commentsDislikesCounts = Array(repeating: 0, count: fetchedComments.count)
                        self.commentsAreLiked = Array(repeating: false, count: fetchedComments.count)
                        self.commentsAreDisliked = Array(repeating: false, count: fetchedComments.count)
                        self.commentsNumberOfReplies = Array(repeating: 0, count: fetchedComments.count)
                        
                        self.comments = fetchedComments
                        
                        self.commentsNextCursor = rawComments.pageInfo.startCursor
                        
                        self.commentsHasNextPageOlder = rawComments.pageInfo.hasPreviousPage
                        
                    }
                case .failure(let error):
                    print("Error fetching comments: \(error)")
                }
            }
        }
    }
    
    func loadOlderComments(reviewID: String) {
        guard let nextCursor = self.commentsNextCursor else { return }
        
        if fetchingMostPopular {
            let query = STARSAPI.GetAReviewsCommentsMostPopularQuery(reviewID: reviewID, commentsFirst: .some(self.pageSize), commentsAfter: .some(self.commentsNextCursor!))
            
            Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
                switch result {
                case .success(let graphQLResult):
                    if let rawComments = graphQLResult.data?.reviews.edges.first?.node.comments {
                        let newComments = rawComments.edges.compactMap{ $0.node.fragments.commentFragment }
                        
                        self.commentsLikesCounts.append(contentsOf: Array(repeating: 0, count: newComments.count))
                        self.commentsDislikesCounts.append(contentsOf: Array(repeating: 0, count: newComments.count))
                        self.commentsAreLiked.append(contentsOf: Array(repeating: false, count: newComments.count))
                        self.commentsAreDisliked.append(contentsOf: Array(repeating: false, count: newComments.count))
                        self.commentsNumberOfReplies.append(contentsOf: Array(repeating: 0, count: newComments.count))
                        
                        DispatchQueue.main.async {
                            withAnimation() {
                                self.comments += newComments
                            }
                            
                            self.commentsNextCursor = rawComments.pageInfo.startCursor
                            
                            self.commentsHasNextPageOlder = rawComments.pageInfo.hasPreviousPage
                        }
                    }
                    
                case .failure(let error):
                    print("Error loading older comments: \(error)")
                }
            }
        }
        
        else {
            let query = STARSAPI.GetAReviewsCommentsLatestQuery(reviewID: reviewID, commentsFirst: .some(self.pageSize), commentsAfter: .some(self.commentsNextCursor!))
            
            Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
                switch result {
                case .success(let graphQLResult):
                    if let rawComments = graphQLResult.data?.reviews.edges.first?.node.comments {
                        let newComments = rawComments.edges.compactMap{ $0.node.fragments.commentFragment }
                        
                        self.commentsLikesCounts.append(contentsOf: Array(repeating: 0, count: newComments.count))
                        self.commentsDislikesCounts.append(contentsOf: Array(repeating: 0, count: newComments.count))
                        self.commentsAreLiked.append(contentsOf: Array(repeating: false, count: newComments.count))
                        self.commentsAreDisliked.append(contentsOf: Array(repeating: false, count: newComments.count))
                        self.commentsNumberOfReplies.append(contentsOf: Array(repeating: 0, count: newComments.count))
                        
                        DispatchQueue.main.async {
                            withAnimation() {
                                self.comments += newComments
                            }
                            
                            self.commentsNextCursor = rawComments.pageInfo.startCursor
                            
                            self.commentsHasNextPageOlder = rawComments.pageInfo.hasPreviousPage
                        }
                    }
                    
                case .failure(let error):
                    print("Error loading older comments: \(error)")
                }
            }
        }
    }
    
    func fetchInitialReplies() {
        self.repliesNextCursor = nil
        self.repliesHasNextPageOlder = false
        
        if let commentID = showingRepliesForCommentID {
            let query = STARSAPI.GetACommentsRepliesQuery(commentID: commentID, repliesFirst: .some(self.replyPageSize), repliesAfter: nil)
            
            Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
                switch result {
                case .success(let graphQLResult):
                    if let rawReplies = graphQLResult.data?.comments.edges.first?.node.replies {
                        let fetchedReplies = rawReplies.edges.compactMap{ $0.node.fragments.commentFragment }
                        
                        self.repliesLikesCounts = Array(repeating: 0, count: fetchedReplies.count)
                        self.repliesDislikesCounts = Array(repeating: 0, count: fetchedReplies.count)
                        self.repliesAreLiked = Array(repeating: false, count: fetchedReplies.count)
                        self.repliesAreDisliked = Array(repeating: false, count: fetchedReplies.count)
                        
                        self.replies = fetchedReplies
                        
                        self.repliesNextCursor = rawReplies.pageInfo.startCursor
                        
                        self.repliesHasNextPageOlder = rawReplies.pageInfo.hasPreviousPage
                        
                        print("has replies previous page: \(rawReplies.pageInfo.hasPreviousPage)")
                        print("has replies next page: \(rawReplies.pageInfo.hasNextPage)")
                        
                    }
                case .failure(let error):
                    print("Error fetching replies: \(error)")
                }
            }
        }
    }
    
    func loadOlderReplies() {
        guard let nextCursor = self.repliesNextCursor else { return }
        
        if let commentID = showingRepliesForCommentID {
            let query = STARSAPI.GetACommentsRepliesQuery(commentID: commentID, repliesFirst: .some(self.replyPageSize), repliesAfter: .some(self.repliesNextCursor!))
            
            Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
                switch result {
                case .success(let graphQLResult):
                    if let rawReplies = graphQLResult.data?.comments.edges.first?.node.replies {
                        let newReplies = rawReplies.edges.compactMap{ $0.node.fragments.commentFragment }
                        
                        self.repliesLikesCounts.append(contentsOf: Array(repeating: 0, count: newReplies.count))
                        self.repliesDislikesCounts.append(contentsOf: Array(repeating: 0, count: newReplies.count))
                        self.repliesAreLiked.append(contentsOf: Array(repeating: false, count: newReplies.count))
                        self.repliesAreDisliked.append(contentsOf: Array(repeating: false, count: newReplies.count))
                        
                        DispatchQueue.main.async {
                            withAnimation() {
                                self.replies += newReplies
                            }
                            
                            self.repliesNextCursor = rawReplies.pageInfo.startCursor
                            
                            self.repliesHasNextPageOlder = rawReplies.pageInfo.hasPreviousPage
                        }
                    }
                    
                case .failure(let error):
                    print("Error loading older replies: \(error)")
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
    
    func likeComment(commentID: String) {
        let mutation = STARSAPI.LikeDislikeCommentMutation(commentID: commentID, action: GraphQLEnum(LikeAction.like))
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
    
    func dislikeComment(commentID: String) {
        let mutation = STARSAPI.LikeDislikeCommentMutation(commentID: commentID, action: GraphQLEnum(LikeAction.dislike))
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
    
    func addComment(reviewID: String, text: String, replyingToCommentID: String? = nil, replyingToCommentIndex: Int? = nil) {
        var data: CommentCreateInput
        
        if replyingToCommentID != nil {
            data = CommentCreateInput(reviewId: reviewID, text: text, replyingToCommentId: .some(replyingToCommentID!))
        }
        else {
            data = CommentCreateInput(reviewId: reviewID, text: text)
        }
        
        let mutation = STARSAPI.CreateCommentMutation(data: data)
        
        Network.shared.apollo.perform(mutation: mutation) { result in
            switch result {
            case .success(let graphQLResult):
                if let errors = graphQLResult.errors {
                    print("GraphQL Error: \(errors)")
                }
                else {
                    if replyingToCommentID != nil {
                        //self.fetchInitialComments(reviewID: reviewID)
                        self.fetchInitialReplies()
                        
                        if let index = replyingToCommentIndex {
                            self.repliesLikesCounts.append(0)
                            self.repliesDislikesCounts.append(0)
                            self.repliesAreLiked.append(false)
                            self.repliesAreDisliked.append(false)
                            
                            self.commentsNumberOfReplies[index] += 1
                        }
                    }
                    else {
                        self.fetchInitialComments(reviewID: reviewID)
                    }
                }
            case .failure(let error):
                print("Network Error: \(error)")
            }
        }
    }
}
    

struct ReviewDetailView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @AppStorage("userID") var userID: String = ""
    
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var isLiked: [Bool] = []
    @State private var isDisliked: [Bool] = []
    
    @State private var likesCount: [Int] = []
    @State private var dislikesCount: [Int] = []
    @State private var commentsCount: [Int] = []
    @State private var newCommentText: [String] = []
    
    @State private var alsoLoaded: Bool = false
    
    @State private var currentPage = 1
    
    @State private var replyingToComment: CommentFragment? = nil
    @State private var replyingToCommentIndex: Int? = nil

    @StateObject private var viewModel: ReviewDetailViewModel

    init(reviewUserID: String, contentType: String, objectID: String, typingNewComment: Bool = false) {
        _viewModel = StateObject(wrappedValue: ReviewDetailViewModel(reviewUserID: reviewUserID, contentType: contentType, objectID: objectID))
        isTextFieldFocused = typingNewComment
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.isLoaded {
                TabView(selection: $currentPage) {
                    if alsoLoaded {
                        ForEach(Array(viewModel.reviews.enumerated()), id: \.element.id) { reviewIndex, review in
                            ZStack {
                                VStack {
                                    ScrollView {
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
                                                StarView(stars: decimalStringToDouble(review.stars) ?? 0)
                                                    .bold()
                                                
                                                Text(String(format: "%.1f", decimalStringToDouble(review.stars) ?? 0))
                                                    .bold()
                                                    .foregroundStyle(viewModel.primaryTextColor)
                                                
                                                Spacer()
                                            }
                                            .padding(.top, 5)
                                            .padding(.bottom, -5)
                                            
                                            Divider()
                                                .foregroundStyle(viewModel.primaryTextColor)
                                            
                                            Text(review.title)
                                                .bold()
                                                .foregroundStyle(viewModel.primaryTextColor)
                                            
                                            Text(review.text)
                                                .padding(.vertical, 1)
                                                .foregroundStyle(viewModel.primaryTextColor)
                                            
                                            ForEach(Array(review.subreviews.edges.compactMap{ $0.node }), id: \.id) { subreview in
                                                Text(subreview.topic)
                                                    .bold()
                                                    .foregroundStyle(viewModel.primaryTextColor)
                                                
                                                HStack {
                                                    StarView(stars: decimalStringToDouble(subreview.stars) ?? 0)
                                                        .bold()
                                                    
                                                    Text(String(format: "%.1f", decimalStringToDouble(review.stars) ?? 0))
                                                        .bold()
                                                        .foregroundStyle(viewModel.primaryTextColor)
                                                    
                                                    Spacer()
                                                }
                                                
                                                Text(subreview.text)
                                                    .foregroundStyle(viewModel.primaryTextColor)
                                            }
                                            
                                            Divider()
                                                .foregroundStyle(viewModel.primaryTextColor)
                                            
                                            HStack{
                                                Button {
                                                    likeReview(reviewID: review.id)
                                                    
                                                    if !isLiked[reviewIndex] {
                                                        isLiked[reviewIndex] = true
                                                        likesCount[reviewIndex] += 1
                                                        
                                                        if isDisliked[reviewIndex] {
                                                            isDisliked[reviewIndex] = false
                                                            dislikesCount[reviewIndex] -= 1
                                                        }
                                                    }
                                                    
                                                    else {
                                                        isLiked[reviewIndex] = false
                                                        likesCount[reviewIndex] -= 1
                                                    }
                                                } label: {
                                                    Image(systemName: "hand.thumbsup")
                                                        .symbolVariant(isLiked[reviewIndex] ? .fill : .none)
                                                        .foregroundStyle(viewModel.primaryTextColor)
                                                }
                                                
                                                Text(formatNumber(likesCount[reviewIndex]))
                                                    .font(.subheadline)
                                                    .padding(.trailing)
                                                    .foregroundStyle(viewModel.primaryTextColor)
                                                
                                                Button {
                                                    dislikeReview(reviewID: review.id)
                                                    
                                                    if !isDisliked[reviewIndex] {
                                                        isDisliked[reviewIndex] = true
                                                        dislikesCount[reviewIndex] += 1
                                                        
                                                        if isLiked[reviewIndex] {
                                                            isLiked[reviewIndex] = false
                                                            likesCount[reviewIndex] -= 1
                                                        }
                                                    }
                                                    
                                                    else {
                                                        isDisliked[reviewIndex] = false
                                                        dislikesCount[reviewIndex] -= 1
                                                    }
                                                } label: {
                                                    Image(systemName: "hand.thumbsdown")
                                                        .symbolVariant(isDisliked[reviewIndex] ? .fill : .none)
                                                        .foregroundStyle(viewModel.primaryTextColor)
                                                }
                                                
                                                Text(formatNumber(dislikesCount[reviewIndex]))
                                                    .font(.subheadline)
                                                    .padding(.trailing)
                                                    .foregroundStyle(viewModel.primaryTextColor)
                                                
                                                Button {
                                                    replyingToComment = nil
                                                    replyingToCommentIndex = nil
                                                    isTextFieldFocused = true
                                                } label: {
                                                    Image(systemName: "message")
                                                        .foregroundStyle(viewModel.primaryTextColor)
                                                    
                                                    Text(formatNumber(commentsCount[reviewIndex]))
                                                        .font(.caption)
                                                        .padding(.trailing)
                                                        .foregroundStyle(viewModel.primaryTextColor)
                                                }
                                                
                                                HStack {
                                                    Spacer()
                                                    
                                                    Text((date(from: review.dateCreated) ?? Foundation.Date()).formatted(date: .abbreviated, time: .omitted))
                                                        .font(.footnote)
                                                        .foregroundStyle(viewModel.primaryGrayTextColor)
                                                }
                                            }
                                            
                                            HStack {
                                                LazyVStack {
                                                    if commentsCount[reviewIndex] == 0 {
                                                        Spacer()
                                                        
                                                        HStack {
                                                            Spacer()
                                                            
                                                            Text("No comments")
                                                                .foregroundStyle(viewModel.secondaryTextColor)
                                                            
                                                            Spacer()
                                                        }
                                                        
                                                        Spacer()
                                                    }
                                                    else {
                                                        ForEach(Array(viewModel.comments.enumerated()), id: \.element.id) { commentIndex, comment in
                                                            VStack {
                                                                HStack {
                                                                    if let profilePicture = comment.user.profile.profilePicture {
                                                                        WebImage(url: URL(string: profilePicture))
                                                                            .resizable()
                                                                            .frame(width: 32, height: 32)
                                                                            .clipShape(Circle())
                                                                    }
                                                                    else {
                                                                        Image(systemName: "person.crop.circle")
                                                                            .frame(width: 32, height: 32)
                                                                            .clipShape(Circle())
                                                                            .font(.title)
                                                                            .foregroundStyle(viewModel.secondaryTextColor)
                                                                    }
                                                                    
                                                                    Text("@\(comment.user.username)")
                                                                        .padding(.trailing, 5)
                                                                        .bold()
                                                                        .font(.subheadline)
                                                                        .foregroundStyle(viewModel.secondaryTextColor)
                                                                    
                                                                    Text(timeAgoString(from: date(from: comment.dateCreated) ?? Foundation.Date()))
                                                                        .font(.subheadline)
                                                                        .foregroundStyle(viewModel.secondaryGrayTextColor)
                                                                    
                                                                    Spacer()
                                                                }
                                                                
                                                                HStack {
                                                                    Text(comment.text)
                                                                        .font(.subheadline)
                                                                        .foregroundStyle(viewModel.secondaryTextColor)
                                                                        .padding(.leading, 40)
                                                                    
                                                                    Spacer()
                                                                }
                                                                
                                                                HStack {
                                                                    Button {
                                                                        likeComment(commentID: comment.id)
                                                                        
                                                                        if !viewModel.commentsAreLiked[commentIndex] {
                                                                            viewModel.commentsAreLiked[commentIndex] = true
                                                                            viewModel.commentsLikesCounts[commentIndex] += 1
                                                                            
                                                                            if viewModel.commentsAreDisliked[commentIndex] {
                                                                                viewModel.commentsAreDisliked[commentIndex] = false
                                                                                viewModel.commentsDislikesCounts[commentIndex] -= 1
                                                                            }
                                                                        }
                                                                        
                                                                        else {
                                                                            viewModel.commentsAreLiked[commentIndex] = false
                                                                            viewModel.commentsLikesCounts[commentIndex] -= 1
                                                                        }
                                                                    } label: {
                                                                        Image(systemName: "hand.thumbsup")
                                                                            .symbolVariant(viewModel.commentsAreLiked[commentIndex] ? .fill : .none)
                                                                            .foregroundStyle(viewModel.secondaryTextColor)
                                                                    }
                                                                    
                                                                    Text(formatNumber(viewModel.commentsLikesCounts[commentIndex]))
                                                                        .font(.subheadline)
                                                                        .padding(.trailing)
                                                                        .foregroundStyle(viewModel.secondaryTextColor)
                                                                    
                                                                    Button {
                                                                        dislikeComment(commentID: comment.id)
                                                                        
                                                                        if !viewModel.commentsAreDisliked[commentIndex] {
                                                                            viewModel.commentsAreDisliked[commentIndex] = true
                                                                            viewModel.commentsDislikesCounts[commentIndex] += 1
                                                                            
                                                                            if viewModel.commentsAreLiked[commentIndex] {
                                                                                viewModel.commentsAreLiked[commentIndex] = false
                                                                                viewModel.commentsLikesCounts[commentIndex] -= 1
                                                                            }
                                                                        }
                                                                        
                                                                        else {
                                                                            viewModel.commentsAreDisliked[commentIndex] = false
                                                                            viewModel.commentsDislikesCounts[commentIndex] -= 1
                                                                        }
                                                                    } label: {
                                                                        Image(systemName: "hand.thumbsdown")
                                                                            .symbolVariant(viewModel.commentsAreDisliked[commentIndex] ? .fill : .none)
                                                                            .foregroundStyle(viewModel.secondaryTextColor)
                                                                    }
                                                                    
                                                                    Text(formatNumber(viewModel.commentsDislikesCounts[commentIndex]))
                                                                        .font(.subheadline)
                                                                        .padding(.trailing)
                                                                        .foregroundStyle(viewModel.primaryTextColor)
                                                                    
                                                                    Button {
                                                                        replyingToComment = comment
                                                                        replyingToCommentIndex = commentIndex
                                                                        isTextFieldFocused = true
                                                                        newCommentText[reviewIndex] = "@\(comment.user.username) "
                                                                    } label: {
                                                                        Label("Reply", systemImage: "arrowshape.turn.up.left")
                                                                            .font(.subheadline)
                                                                            .foregroundStyle(viewModel.secondaryTextColor)
                                                                    }
                                                                    
                                                                    Spacer()
                                                                    
                                                                }
                                                                .padding(.top, 2)
                                                                .padding(.bottom, 5)
                                                                .padding(.leading, 40)
                                                            }
                                                            .onAppear {
                                                                viewModel.commentsAreLiked[commentIndex] = comment.likedByCurrentUser
                                                                viewModel.commentsAreDisliked[commentIndex] = comment.dislikedByCurrentUser
                                                                viewModel.commentsLikesCounts[commentIndex] = comment.likesCount
                                                                viewModel.commentsDislikesCounts[commentIndex] = comment.dislikesCount
                                                                viewModel.commentsNumberOfReplies[commentIndex] = comment.numberOfReplies
                                                            }
                                                            
                                                            if viewModel.commentsNumberOfReplies[commentIndex] > 0 {
                                                                HStack {
                                                                    Rectangle()
                                                                        .frame(width: 32, height: 2)
                                                                        .foregroundColor(viewModel.secondaryGrayTextColor)
                                                                    
                                                                    Button {
                                                                        if viewModel.showingRepliesForCommentID == comment.id {
                                                                            viewModel.showingRepliesForCommentID = nil
                                                                        }
                                                                        else {
                                                                            viewModel.replies = []
                                                                            viewModel.showingRepliesForCommentID = comment.id
                                                                            viewModel.fetchInitialReplies()
                                                                        }
                                                                    } label: {
                                                                        
                                                                        Text(viewModel.showingRepliesForCommentID == comment.id ? "Hide replies" : (viewModel.commentsNumberOfReplies[commentIndex] == 1 ? "Show 1 reply" : "Show \(viewModel.commentsNumberOfReplies[commentIndex]) replies"))
                                                                            .font(.subheadline)
                                                                            .foregroundStyle(viewModel.secondaryGrayTextColor)
                                                                    }
                                                                    
                                                                    Spacer()
                                                                }
                                                                .padding(.leading, 40)
                                                            }
                                                            
                                                            if let commentID = viewModel.showingRepliesForCommentID {
                                                                if commentID == comment.id {
                                                                    ForEach(Array(viewModel.replies.enumerated()), id: \.element.id) { replyIndex, reply in
                                                                        VStack {
                                                                            HStack {
                                                                                if let profilePicture = reply.user.profile.profilePicture {
                                                                                    WebImage(url: URL(string: profilePicture))
                                                                                        .resizable()
                                                                                        .frame(width: 32, height: 32)
                                                                                        .clipShape(Circle())
                                                                                }
                                                                                else {
                                                                                    Image(systemName: "person.crop.circle")
                                                                                        .frame(width: 32, height: 32)
                                                                                        .clipShape(Circle())
                                                                                        .font(.title)
                                                                                        .foregroundStyle(viewModel.secondaryTextColor)
                                                                                }
                                                                                
                                                                                Text("@\(reply.user.username)")
                                                                                    .padding(.trailing, 5)
                                                                                    .bold()
                                                                                    .font(.subheadline)
                                                                                    .foregroundStyle(viewModel.secondaryTextColor)
                                                                                
                                                                                Text(timeAgoString(from: date(from: reply.dateCreated) ?? Foundation.Date()))
                                                                                    .font(.subheadline)
                                                                                    .foregroundStyle(viewModel.secondaryGrayTextColor)
                                                                                
                                                                                Spacer()
                                                                            }
                                                                            
                                                                            HStack {
                                                                                Text(reply.text)
                                                                                    .font(.subheadline)
                                                                                    .foregroundStyle(viewModel.secondaryTextColor)
                                                                                    .padding(.leading, 40)
                                                                                
                                                                                Spacer()
                                                                            }
                                                                            
                                                                            HStack {
                                                                                Button {
                                                                                    likeComment(commentID: reply.id)
                                                                                    
                                                                                    if !viewModel.repliesAreLiked[replyIndex] {
                                                                                        viewModel.repliesAreLiked[replyIndex] = true
                                                                                        viewModel.repliesLikesCounts[replyIndex] += 1
                                                                                        
                                                                                        if viewModel.repliesAreDisliked[replyIndex] {
                                                                                            viewModel.repliesAreDisliked[replyIndex] = false
                                                                                            viewModel.repliesDislikesCounts[replyIndex] -= 1
                                                                                        }
                                                                                    }
                                                                                    
                                                                                    else {
                                                                                        viewModel.repliesAreLiked[replyIndex] = false
                                                                                        viewModel.repliesLikesCounts[replyIndex] -= 1
                                                                                    }
                                                                                } label: {
                                                                                    Image(systemName: "hand.thumbsup")
                                                                                        .symbolVariant(viewModel.repliesAreLiked[replyIndex] ? .fill : .none)
                                                                                        .foregroundStyle(viewModel.secondaryTextColor)
                                                                                }
                                                                                
                                                                                Text(formatNumber(viewModel.repliesLikesCounts[replyIndex]))
                                                                                    .font(.subheadline)
                                                                                    .padding(.trailing)
                                                                                    .foregroundStyle(viewModel.secondaryTextColor)
                                                                                
                                                                                Button {
                                                                                    dislikeComment(commentID: reply.id)
                                                                                    
                                                                                    if !viewModel.repliesAreDisliked[replyIndex] {
                                                                                        viewModel.repliesAreDisliked[replyIndex] = true
                                                                                        viewModel.repliesDislikesCounts[replyIndex] += 1
                                                                                        
                                                                                        if viewModel.repliesAreLiked[replyIndex] {
                                                                                            viewModel.repliesAreLiked[replyIndex] = false
                                                                                            viewModel.repliesLikesCounts[replyIndex] -= 1
                                                                                        }
                                                                                    }
                                                                                    
                                                                                    else {
                                                                                        viewModel.repliesAreDisliked[replyIndex] = false
                                                                                        viewModel.repliesDislikesCounts[replyIndex] -= 1
                                                                                    }
                                                                                } label: {
                                                                                    Image(systemName: "hand.thumbsdown")
                                                                                        .symbolVariant(viewModel.repliesAreDisliked[replyIndex] ? .fill : .none)
                                                                                        .foregroundStyle(viewModel.secondaryTextColor)
                                                                                }
                                                                                
                                                                                Text(formatNumber(viewModel.repliesDislikesCounts[replyIndex]))
                                                                                    .font(.subheadline)
                                                                                    .padding(.trailing)
                                                                                    .foregroundStyle(viewModel.primaryTextColor)
                                                                                
                                                                                Button {
                                                                                    replyingToComment = comment
                                                                                    replyingToCommentIndex = commentIndex
                                                                                    isTextFieldFocused = true
                                                                                    newCommentText[replyIndex] = "@\(reply.user.username) "
                                                                                } label: {
                                                                                    Label("Reply", systemImage: "arrowshape.turn.up.left")
                                                                                        .font(.subheadline)
                                                                                        .foregroundStyle(viewModel.secondaryTextColor)
                                                                                }
                                                                                
                                                                                Spacer()
                                                                                
                                                                            }
                                                                            .padding(.top, 2)
                                                                            .padding(.bottom, 5)
                                                                            .padding(.leading, 40)
                                                                            
                                                                        }
                                                                        .onAppear {
                                                                            viewModel.repliesAreLiked[replyIndex] = reply.likedByCurrentUser
                                                                            viewModel.repliesAreDisliked[replyIndex] = reply.dislikedByCurrentUser
                                                                            viewModel.repliesLikesCounts[replyIndex] = reply.likesCount
                                                                            viewModel.repliesDislikesCounts[replyIndex] = reply.dislikesCount
                                                                        }
                                                                    }
                                                                    .padding(.leading, 40)
                                                                    
                                                                    if viewModel.repliesHasNextPageOlder {
                                                                        HStack {
                                                                            Rectangle()
                                                                                .frame(width: 32, height: 2)
                                                                                .foregroundColor(viewModel.secondaryGrayTextColor)
                                                                            
                                                                            Button {
                                                                                viewModel.loadOlderReplies()
                                                                            } label: {
                                                                                Text("Show more replies")
                                                                                    .font(.subheadline)
                                                                                    .foregroundStyle(viewModel.secondaryGrayTextColor)
                                                                            }
                                                                            
                                                                            Spacer()
                                                                        }
                                                                        padding(.leading, 40)
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        
                                                        if viewModel.commentsHasNextPageOlder {
                                                            ProgressView()
                                                                .onAppear {
                                                                    viewModel.loadOlderComments(reviewID: review.id)
                                                                }
                                                        }
                                                        
                                                        Spacer()
                                                    }
                                                }
                                                
                                                Spacer()
                                            }
                                            .onAppear {
                                                print(viewModel.comments.count)
                                            }
                                            .padding(5)
                                            .background {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundStyle(viewModel.secondaryBgColor)
                                                    .shadow(radius: 3)
                                            }
                                        }
                                        .onAppear {
                                            isLiked[reviewIndex] = review.likedByCurrentUser
                                            isDisliked[reviewIndex] = review.dislikedByCurrentUser
                                            likesCount[reviewIndex] = review.likesCount
                                            dislikesCount[reviewIndex] = review.dislikesCount
                                            commentsCount[reviewIndex] = review.commentsCount
                                        }
                                    }
                                    .scrollIndicators(.hidden)
                                    .padding([.top, .horizontal])
                                    
                                    HStack {
                                        if isTextFieldFocused {
                                            Button {
                                                isTextFieldFocused.toggle()
                                            } label: {
                                                Image(systemName: "chevron.down")
                                                    .font(.subheadline)
                                                    .foregroundStyle(viewModel.primaryTextColor)
                                            }
                                        }
                                                                                
                                        ZStack(alignment: .topLeading) {
                                            if newCommentText[reviewIndex].isEmpty {
                                                if let replyingToComment = replyingToComment {
                                                    Text("Reply to @\(replyingToComment.user.username)...")
                                                        .font(.subheadline)
                                                        .foregroundStyle(viewModel.secondaryGrayTextColor)
                                                        .padding(.horizontal, 5)
                                                        .padding(.vertical, 8)
                                                }
                                                else {
                                                    Text("Comment on this review...")
                                                        .font(.subheadline)
                                                        .foregroundStyle(viewModel.secondaryGrayTextColor)
                                                        .padding(.horizontal, 5)
                                                        .padding(.vertical, 8)
                                                }
                                            }
                                            
                                            TextEditor(text: $newCommentText[reviewIndex])
                                                .scrollContentBackground(.hidden)
                                                .frame(minHeight: 20, maxHeight: 160)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .cornerRadius(10)
                                                .font(.subheadline)
                                                .foregroundStyle(viewModel.secondaryTextColor)
                                                .tint(viewModel.secondaryGrayTextColor)
                                                .focused($isTextFieldFocused)
                                                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                                                    replyingToComment = nil
                                                    replyingToCommentIndex = nil
                                                    newCommentText[reviewIndex] = ""
                                                }
                                        }
                                        .background(viewModel.secondaryBgColor)
                                        .cornerRadius(10)
                                        
                                        Button {
                                            viewModel.addComment(reviewID: review.id, text: newCommentText[reviewIndex], replyingToCommentID: replyingToComment?.id ?? nil, replyingToCommentIndex: replyingToCommentIndex)
                                            commentsCount[reviewIndex] += 1
                                            newCommentText[reviewIndex] = ""
                                            isTextFieldFocused = false
                                        } label: {
                                            Image(systemName: "paperplane.fill")
                                                .bold()
                                                .font(.subheadline)
                                                .foregroundStyle(isCommentNotEmpty(newCommentText[reviewIndex]) ? viewModel.primaryTextColor : viewModel.primaryGrayTextColor)
                                        }
                                        .disabled(!isCommentNotEmpty(newCommentText[reviewIndex]))
                                    }
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(viewModel.primaryBgColor)
                                            .shadow(radius: 3)
                                    }
                                }
                            }
                            .padding(.top, viewModel.reviews.count == 1 ? 0 : 32)
                            .tag(reviewIndex)
                            
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
                        .rotationEffect(.degrees(180))
                    }
                }
                .rotationEffect(.degrees(180))
                .tabViewStyle(.page)
                .onChange(of: currentPage) { oldValue, newValue in
                    guard newValue >= 0, newValue < viewModel.reviews.count else { return }
                    viewModel.fetchInitialComments(reviewID: viewModel.reviews[newValue].id)
                }
                .onAppear {
                    DispatchQueue.main.async {
                        currentPage = viewModel.reviews.count - 1
                        
                        isLiked = Array(repeating: false, count: viewModel.reviews.count)
                        isDisliked = Array(repeating: false, count: viewModel.reviews.count)
                        
                        likesCount = Array(repeating: 0, count: viewModel.reviews.count)
                        dislikesCount = Array(repeating: 0, count: viewModel.reviews.count)
                        commentsCount = Array(repeating: 0, count: viewModel.reviews.count)
                        
                        newCommentText = Array(repeating: "", count: viewModel.reviews.count)
                        
                        alsoLoaded = true
                    }
                }
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(viewModel.primaryBgColor)
                .shadow(radius: 3)
        }
        .padding(.horizontal)
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.setDataManager(DataManager.shared)
            
            viewModel.fetchInitialData()
        }
    }
    
    func likeReview(reviewID: String) {
        viewModel.likeReview(reviewID: reviewID)
    }
    
    func dislikeReview(reviewID: String) {
        viewModel.dislikeReview(reviewID: reviewID)
    }
    
    func likeComment(commentID: String) {
        viewModel.likeComment(commentID: commentID)
    }
    
    func dislikeComment(commentID: String) {
        viewModel.dislikeComment(commentID: commentID)
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
    
    func timeAgoString(from date: Foundation.Date) -> String {
        let now = Foundation.Date()
        let seconds = max(0, Int(now.timeIntervalSince(date)))
        
        if seconds < 60 {
            return "\(seconds)s"
        }
        
        let minutes = seconds / 60
        if minutes < 60 {
            return "\(minutes)m"
        }
        
        let hours = minutes / 60
        if hours < 24 {
            return "\(hours)h"
        }
        
        let days = hours / 24
        if days < 365 {
            return "\(days)d"
        }
        
        let years = days / 365
        return "\(years)y"
    }
    
    func isCommentNotEmpty(_ string: String) -> Bool {
        // Trim leading/trailing whitespace and newlines
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If string is empty after trimming → return false
        if trimmed.isEmpty { return false }
        
        // Regex for @username at the start
        let regex = try! NSRegularExpression(pattern: #"^@[a-z0-9._]+\s*"#)
        let range = NSRange(location: 0, length: trimmed.utf16.count)
        
        // Remove the @username part if it exists
        let result = regex.stringByReplacingMatches(in: trimmed, options: [], range: range, withTemplate: "")
        
        // If there’s anything left after removing username + spaces → return true
        return !result.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    //ReviewDetailView()
}

