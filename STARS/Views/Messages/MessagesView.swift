//
//  MessagesView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 08.12.2024.
//

import Foundation
import SwiftUI
import Combine
import STARSAPI
import Apollo
import SDWebImageSwiftUI

// This ViewModel will be the "brain" for your ConversationView
@MainActor
class MessagesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var conversations: [ConversationFragment] = []
    
    // MARK: - Properties
    private var subscription: Apollo.Cancellable?
    @AppStorage("userID") private var userID: String = ""
    
    private var pageSize = 20
    private var nextCursor: String? = nil
    @Published var hasNextPageOlder = false

    deinit {
        subscription?.cancel()
    }
    
    // MARK: - Public Methods
    
    func cancelSubscription() {
        subscription?.cancel()
    }
    
    func fetchInitialData() {
        let query = STARSAPI.GetUserConversationsQuery(
            userID: self.userID,
            last: .some(pageSize),
            before: nil
        )
        
        Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
            switch result {
            case .success(let graphQLResult):
                if let user = graphQLResult.data?.users.edges.first?.node {
                    // Find the other participant in the conversation
                    self.conversations = user.conversations.edges.compactMap { $0.node.fragments.conversationFragment }
                    
                    self.nextCursor = user.conversations.pageInfo.startCursor
                    
                    self.hasNextPageOlder = user.conversations.pageInfo.hasPreviousPage
                    
                    self.startSubscription()
                }
            case .failure(let error):
                print("Error fetching conversations: \(error)")
            }
        }
    }
    
    func loadOlderConversations() {
        guard let nextCursor = self.nextCursor else { return }
        
        let query = STARSAPI.GetUserConversationsQuery(
            userID: self.userID,
            last: .some(pageSize),
            before: .some(nextCursor)
        )
                
        Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
            switch result {
            case .success(let graphQLResult):
                if let user = graphQLResult.data?.users.edges.first?.node {
                    // Find the other participant in the conversation
                    let newConversations = user.conversations.edges.compactMap { $0.node.fragments.conversationFragment }
                    
                    DispatchQueue.main.async {
                        self.conversations += newConversations
                        
                        self.nextCursor = user.conversations.pageInfo.startCursor
                        
                        self.hasNextPageOlder = user.conversations.pageInfo.hasPreviousPage
                    }
                }
                
            case .failure(let error):
                print("Error loading older conversations: \(error)")
            }
        }
    }
    
    func likeMessage(id: String) {
        let mutation = STARSAPI.LikeMessageMutation(id: id)
        Network.shared.apollo.perform(mutation: mutation) { result in
            switch result {
            case .success(let graphQLResult):
                if let message = graphQLResult.data?.likeMessage.message {
                    print("Server response: \(message)")
                }
                if let errors = graphQLResult.errors {
                    print("GraphQL Error: \(errors)")
                }
            case .failure(let error):
                print("Network Error: \(error)")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func startSubscription() {
        let sub = STARSAPI.ConversationUpdatesSubscription()
        
        self.subscription = Network.shared.apollo.subscribe(subscription: sub) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let graphQLResult):
                guard let eventData = graphQLResult.data?.conversationUpdates else { return }
                
                let conversation = eventData.conversation.fragments.conversationFragment
                    
                if conversation.participants.edges.contains(where: {$0.node.id == self.userID}) {
                    DispatchQueue.main.async {
                        withAnimation(.bouncy()) {
                            self.conversations.removeAll { $0.id == conversation.id }
                            self.conversations.insert(conversation, at: 0)
                        }
                    }
                }
                
            case .failure(let error):
                print("Subscription Error: \(error)")
            }
        }
    }
}

struct MessagesView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    
    

    @StateObject private var viewModel: MessagesViewModel
    
    @AppStorage("userID") var userID: String = ""
    
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    init() {
        _viewModel = StateObject(wrappedValue: MessagesViewModel())
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            VStack {
                if viewModel.conversations.isEmpty {
                    ProgressView()
                } else {
                    ScrollViewReader{ scrollViewProxy in
                        ScrollView {
                            LazyVStack {
                                if viewModel.hasNextPageOlder {
                                    ProgressView()
                                        .onAppear {
                                            viewModel.loadOlderConversations()
                                        }
                                }
                                // Filter conversations based on the search query
                                ForEach(viewModel.conversations, id: \.id) { conversation in
                                    NavigationLink {
                                        ConversationView(conversationID: conversation.id)
                                    } label: {
                                        HStack {
                                            let personYouAreTalkingTo = conversation.participants.edges.first(where: { $0.node.id != userID })!.node
                                            if personYouAreTalkingTo.profile.profilePicture == "" || personYouAreTalkingTo.profile.profilePicture == nil {
                                                Image(systemName: "person.circle")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 64, height: 64)
                                                    .clipShape(Circle())
                                            }
                                            else {
                                                WebImage(url: URL(string: (personYouAreTalkingTo.profile.profilePicture)!))
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 64, height: 64)
                                                    .clipShape(Circle())
                                            }
                                            
                                            VStack(alignment: .leading) {
                                                ProfileNameAndPronounsView(displayName: personYouAreTalkingTo.firstName, username: personYouAreTalkingTo.username, pronouns: personYouAreTalkingTo.profile.pronouns)
                                                
                                                if conversation.seenBy.edges.contains(where: { $0.node.id == userID }) {
                                                    HStack {
                                                        Text(conversation.latestMessageSender?.id == userID ? "You: " + conversation.latestMessageText : conversation.latestMessageText)
                                                            .font(.subheadline)
                                                            .foregroundColor(.gray)
                                                            .lineLimit(1)
                                                            .truncationMode(.tail)
                                                        
                                                        Text("•")
                                                            .font(.subheadline)
                                                            .foregroundColor(.gray)
                                                        
                                                        Text(formatDate(date(from: conversation.latestMessageTime!) ?? Foundation.Date()))
                                                            .font(.subheadline)
                                                            .foregroundColor(.gray)
                                                    }
                                                }
                                                
                                                else {
                                                    HStack {
                                                        Text(conversation.latestMessageSender?.id == userID ? "You: " + conversation.latestMessageText : conversation.latestMessageText)
                                                            .font(.subheadline)
                                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                                            .bold()
                                                            .lineLimit(1)
                                                            .truncationMode(.tail)
                                                        
                                                        Text("•")
                                                            .font(.subheadline)
                                                            .foregroundColor(.gray)
                                                        
                                                        Text(formatDate(date(from: conversation.latestMessageTime!) ?? Foundation.Date()))
                                                            .font(.subheadline)
                                                            .foregroundColor(.gray)
                                                    }
                                                }
                                            }
                                            
                                            Spacer()
                                        }
                                    }
                                    
                                    Divider()
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        newConversation()
                    } label: {
                        Image(systemName: "plus")
                            .bold()
                    }
                }
            }
            .toolbar(removing: .sidebarToggle)
        } detail: {
            Text("Select a conversation")
        }
        .navigationBarHidden(true)
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            NotificationCenter.default.post(name: .showTabBar, object: nil)
            DataManager.shared.shouldShowTabBar = true
            viewModel.fetchInitialData()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                viewModel.fetchInitialData()
            case .background:
                print("App went to background")
                viewModel.cancelSubscription()
                break
            case .inactive:
                viewModel.cancelSubscription()
                break
            @unknown default:
                break
            }
        }
    }
    
    func newConversation() {
        
    }
    
    private func date(from string: String) -> Foundation.Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: string)
    }
    
    func formatDate(_ date: Foundation.Date) -> String {
        let calendar = Calendar.current
        let now = Foundation.Date()
        
        // Check if it's today
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a" // Hour in 12-hour format
            return formatter.string(from: date)
        }
        
        // Check if it's this week
        if let weekAgo = calendar.date(byAdding: .day, value: -7, to: now),
           date >= weekAgo {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // Day of the week
            return formatter.string(from: date)
        }
        
        // More than a week ago, show day and month
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM" // Day and month
        return formatter.string(from: date)
    }
}

#Preview {
    MessagesView()
}
