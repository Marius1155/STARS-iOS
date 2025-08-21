//
//  MessagesView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 08.12.2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct MessagesView: View {
    @EnvironmentObject var dataManager: DataManager
    /*@AppStorage("userID") var userID: String = ""
    
    @State private var conversations: [Conversation] = []
    @State private var userProfiles: [String: Profile] = [:] // Cache for user info
    @State private var listener: ListenerRegistration?
    @State private var newestConversationListener: ListenerRegistration?
    @State private var oldestConversationListener: ListenerRegistration?
    
    @State private var lastConversation: DocumentSnapshot? = nil
    @State private var passItOnAsLastConversation: DocumentSnapshot? = nil
    
    @State private var newestConversationID: String? = nil
    @State private var oldestConversationID: String? = nil
    
    @State private var columnVisibility = NavigationSplitViewVisibility.all*/
    
    var body: some View {
        NavigationLink {
            ConversationView(conversationID: "1")
        } label: {
            Image(systemName: "message.fill")
        }
        .simultaneousGesture(TapGesture().onEnded {
            if let root = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                .first?.rootViewController as? UITabBarController,
               let nav = root.selectedViewController as? UINavigationController {
                
                let convoVC = UIHostingController(rootView: ConversationView(conversationID: "1"))
                convoVC.hidesBottomBarWhenPushed = true
                nav.pushViewController(convoVC, animated: true)
            }
        })
        .onAppear {
            NotificationCenter.default.post(name: .showTabBar, object: nil)
            dataManager.shouldShowTabBar = true
        }
        /*NavigationSplitView(columnVisibility: $columnVisibility) {
            VStack {
                if conversations.isEmpty {
                    Text("Loading...")
                } else {
                    ScrollView {
                        if let newestID = newestConversationID, conversations.first?.id != newestID {
                            Button {
                                passItOnAsLastConversation = nil
                            } label: {
                                Image(systemName: "chevron.up.2")
                                    .padding(10)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.gray.opacity(0.1))
                                    }
                            }
                            .padding()
                        }
                        // Filter conversations based on the search query
                        ForEach(conversations, id: \.id) { conversation in
                            let otherUserID = conversation.userA == userID ? conversation.userB : conversation.userA
                            let userProfile = userProfiles[otherUserID]
                            
                            NavigationLink {
                                ConversationView(conversationID: conversation.id!, otherUserID: otherUserID)
                            } label: {
                                HStack {
                                    if let profile = userProfile {
                                        if profile.profilePicture == "" {
                                            Image(systemName: "person.circle")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 64, height: 64)
                                                .clipShape(Circle())
                                        }
                                        else {
                                            WebImage(url: URL(string: profile.profilePicture))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 64, height: 64)
                                                .clipShape(Circle())
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            ProfileNameAndPronounsView(name: profile.name, pronouns: profile.pronouns)
                                            
                                            HStack {
                                                Text(conversation.latestMessageSender == userID ? "You: " + conversation.latestMessageText : conversation.latestMessageText)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)
                                                
                                                Text("•")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                
                                                Text(formatDate(conversation.latestMessageTime))
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    } else {
                                        ProgressView() // Show a loading indicator while fetching user data
                                    }
                                    Spacer()
                                }
                                .onAppear {
                                    fetchUserProfile(userID: otherUserID)
                                }
                            }
                            
                            Divider()
                        }
                        
                        if let oldestID = oldestConversationID, conversations.last?.id != oldestID {
                            Button {
                                passItOnAsLastConversation = lastConversation
                            } label: {
                                Image(systemName: "chevron.down")
                                    .padding(10)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.gray.opacity(0.1))
                                    }
                            }
                            .padding()
                        }
                        
                    }
                    .padding()
                }
            }
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Add new conversation action
                    } label: {
                        Image(systemName: "plus")
                            .bold()
                    }
                }
            }
            .toolbar(removing: .sidebarToggle)
            .onChange(of: passItOnAsLastConversation) { oldValue, newValue in
                // Trigger your listener again when passItOnAsLastConversation changes
                listener?.remove()  // Remove old listener (to avoid duplication)
                listener = dataManager.listenForConversations(userID: userID, lastConversation: newValue) { updatedConversations, newLastConversation in
                    conversations = updatedConversations
                    lastConversation = newLastConversation
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    newestConversationListener = dataManager.getIDOfTheNewestConversation(userID: userID){ id1 in
                        newestConversationID = id1
                    }
                    
                    oldestConversationListener = dataManager.getIDOfTheOldestConversation(userID: userID) { id2 in
                        oldestConversationID = id2
                    }
                    
                    listener = dataManager.listenForConversations(userID: userID, lastConversation: passItOnAsLastConversation) { updatedConversations, newLastConversation in
                        conversations = updatedConversations
                        lastConversation = newLastConversation
                    }
                }
            }
            .onDisappear {
                listener?.remove()
                newestConversationListener?.remove()
                oldestConversationListener?.remove()
            }
        } detail: {
            Text("Select a conversation")
        }
        .navigationBarHidden(true)
        .navigationSplitViewStyle(.balanced)*/
    }
    /*
    // Fetch user profile only if not already cached
    func fetchUserProfile(userID: String) {
        if userProfiles[userID] != nil { return } // Already cached, no need to fetch
        
        let db = Firestore.firestore()
        db.collection("Profile").document(userID).getDocument(source: .default) { document, error in
            guard let data = document?.data(), error == nil else {
                print("Failed to fetch user profile for \(userID)")
                return
            }
            
            let name = data["name"] as? String ?? ""
            let profilePicture = data["profilePicture"] as? String ?? ""
            let pronouns = data["pronouns"] as? String ?? ""
            
            var profile = Profile.empty()
            profile.setID(userID)
            profile.setProfilePicture(profilePicture)
            profile.setName(name)
            profile.setPronouns(pronouns)
            
            // Store in cache
            userProfiles[userID] = profile
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
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
    }*/
}

#Preview {
    /*MessagesView()
        .environmentObject(DataManager())*/
}
