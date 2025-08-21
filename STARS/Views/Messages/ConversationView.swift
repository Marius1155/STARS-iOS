//
//  ConversationView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 23.02.2025.
//

import Foundation
import SwiftUI
import Combine
import STARSAPI
import Apollo


// This ViewModel will be the "brain" for your ConversationView
@MainActor
class ConversationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var messages: [MessageFragment] = []
    @Published var otherUser: GetConversationQuery.Data.Conversation.Participant?
    
    // MARK: - Properties
    private let conversationID: String
    private var subscription: Apollo.Cancellable?
    @AppStorage("userID") private var userID: String = ""

    init(conversationID: String) {
        self.conversationID = conversationID
    }
    
    deinit {
        // Cancel the subscription when the view model is deallocated
        subscription?.cancel()
    }

    // MARK: - Public Methods
    
    func fetchInitialData() {
        // Fetch the first page of messages (e.g., the latest 50)
        let paging = STARSAPI.OffsetPaginationInput(offset: 0, limit: 200)
        let query = STARSAPI.GetConversationQuery(conversationId: conversationID, messagesPaging: .some(paging))
        
        Network.shared.apollo.fetch(query: query) { result in
            switch result {
            case .success(let graphQLResult):
                if let conversation = graphQLResult.data?.conversations.first {
                    // Find the other participant in the conversation
                    self.otherUser = conversation.participants.first(where: { $0.id != self.userID })
                    
                    // Update the messages, reversing them for chronological display
                    self.messages = conversation.messages.compactMap { $0.fragments.messageFragment }.reversed()
                    // Now that we have the initial data, start the real-time subscription
                    self.startSubscription()
                }
            case .failure(let error):
                print("Error fetching conversation: \(error)")
            }
        }
    }
    
    func sendMessage(text: String, replyingToMessageID: String?) {
        let input: STARSAPI.MessageDataInput
        
        if let replyingToMessageID = replyingToMessageID {
            input = STARSAPI.MessageDataInput(
                text: text,
                replyingToMesssageId: .some(replyingToMessageID)
            )
        } else {
            input = STARSAPI.MessageDataInput(text: text)
        }
        
        Network.shared.apollo.perform(mutation: STARSAPI.AddMessageToConversationMutation(conversationId: conversationID, data: input)) { result in
            switch result {
            case .success(let graphQLResult):
                if let errors = graphQLResult.errors {
                    print("Error sending message: \(errors)")
                }
                // We don't need to manually add the message here,
                // the subscription will deliver it automatically.
            case .failure(let error):
                print("Network error sending message: \(error)")
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
        let sub = STARSAPI.MessageEventsSubscription(conversationId: Int(conversationID) ?? 0)
        
        self.subscription = Network.shared.apollo.subscribe(subscription: sub) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let graphQLResult):
                guard let eventData = graphQLResult.data?.messageEvents else { return }
                
                // Handle the union types
                if let messagePayload = eventData.asMessagePayload {
                    let eventType = messagePayload.eventType
                    let messageFragment = messagePayload.message.fragments.messageFragment
                    
                    switch eventType {
                    case "created":
                        self.messages.append(messageFragment)
                    case "updated":
                        if let index = self.messages.firstIndex(where: { $0.id == messageFragment.id }) {
                            self.messages[index] = messageFragment
                        }
                    default:
                        break
                    }
                    
                } else if let deletedPayload = eventData.asMessageDeletedPayload {
                    let deletedID = deletedPayload.id
                    self.messages.removeAll(where: { $0.id == deletedID })
                    print("message deleted")
                }
                
            case .failure(let error):
                print("Subscription Error: \(error)")
            }
        }
    }
}

// MARK: - VIEW
import SwiftUI
import SDWebImageSwiftUI
import STARSAPI

struct ConversationView: View {
    @EnvironmentObject var dataManager: DataManager
    
    @StateObject private var viewModel: ConversationViewModel
    
    @FocusState private var isTextFieldFocused: Bool
    
    @AppStorage("userID") var userID: String = ""
    
    @State private var newMessageText: String = ""
    
    @State private var lastMessageIsShowed: Bool = true
    
    @State private var dragAmount: CGFloat = 0
    @State private var isDraggingHorizontally = false
    
    @State private var hasScrolledInitially = false
    
    @State private var showActionSheet = false
    @State private var selectedMessage: MessageFragment? = nil
    
    @State private var replyingToMessage: MessageFragment? = nil
    @State private var messageBeingDraggedForReplyingID: String = ""
    @State private var isDraggingHorizontallyForReply: Bool = false
    @State private var dragAmountForReplying: CGFloat = 0
    @State private var alreadyPlayedHapticFeedbackForMessageReply: Bool = false
    @State private var dragStartTime: Foundation.Date? = nil
    
    init(conversationID: String) {
        _viewModel = StateObject(wrappedValue: ConversationViewModel(conversationID: conversationID))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            if let otherUser = viewModel.otherUser {
                NavigationLink {
                    ProfileView(id: otherUser.id)
                } label: {
                    HStack {
                        // ProfilePictureView(pictureURL: otherUser.profile.profilePicture, diameter: 64)
                        VStack(alignment: .leading) {
                            if !otherUser.firstName.isEmpty {
                                Text(otherUser.firstName)
                                    .font(.headline)
                            } else {
                                Text("@\(otherUser.username)")
                                    .font(.headline)
                            }
                            Text(otherUser.profile.pronouns)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                }
            } else {
                ProgressView().padding()
            }
            
            // MARK: - Messages List
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 50, coordinateSpace: .global)
                                    .onChanged { value in
                                        if !isDraggingHorizontally {
                                            isDraggingHorizontally = abs(value.translation.width) > abs(value.translation.height)
                                        }
                                        
                                        if isDraggingHorizontally {
                                            withAnimation{
                                                dragAmount = min(max(value.translation.width, -75), 0)
                                            }// Limit horizontal drag
                                        }
                                    }
                                    .onEnded { _ in
                                        withAnimation(.spring()) {
                                            dragAmount = 0
                                        }
                                        isDraggingHorizontally = false // Reset state
                                    }
                            )
                        VStack {
                            ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, message in
                                VStack {
                                    if index == 0 {
                                        if let currentDate = date(from: message.time) {
                                            Text(formattedTimestamp(for: currentDate))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .padding(.vertical, 5)
                                        }
                                    } else {
                                        if let currentDate = date(from: message.time),
                                           let previousDate = date(from: viewModel.messages[index - 1].time) {
                                            
                                            if currentDate.timeIntervalSince(previousDate) > 1800 {
                                                Text(formattedTimestamp(for: currentDate))
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                    .padding(.vertical, 5)
                                            }
                                        }
                                    }
                                    
                                    ZStack {
                                        //MARK: - Beginning of old MessageBubble
                                        HStack {
                                            if message.sender?.id == userID {
                                                Spacer()
                                            }
                    
                                            HStack {
                                                VStack(alignment: message.sender?.id == userID ? .trailing : .leading) {
                                                    if let replyingToMessage = message.replyingTo {
                                                        Text(
                                                            "\(message.sender?.id == userID ? "You" : (message.sender?.firstName.isEmpty == false ? message.sender!.firstName : "@\(message.sender?.username ?? "Unknown")")) replied to \(replyingToMessage.sender?.id == userID ? "you" : (replyingToMessage.sender?.firstName.isEmpty == false ? replyingToMessage.sender!.firstName : "@\(replyingToMessage.sender?.username ?? "Unknown")"))"
                                                        )
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                        
                                                        Text(replyingToMessage.text)
                                                            .font(.subheadline)
                                                            .foregroundColor(.gray)
                                                            .padding(10)
                                                            .background(Color(.systemGray6))
                                                            .cornerRadius(15)
                                                            .padding(.top, -5)
                                                            .padding(.bottom, -10)
                                                            .onTapGesture {
                                                                if let targetMessage = viewModel.messages.first(where: { $0.id == replyingToMessage.id }) {
                                                                    withAnimation {
                                                                        scrollViewProxy.scrollTo(targetMessage.id, anchor: .top)
                                                                    }
                                                                }
                                                            }
                                                    }
                                                    Text(message.text)
                                                        .padding(10)
                                                        .background(message.sender?.id == userID ? Color.accentColor : Color(.systemGray5))
                                                        .foregroundColor(message.sender?.id == userID ? .white : .primary)
                                                        .cornerRadius(15)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                        .confirmationDialog(
                                                            "Message Options",
                                                            isPresented: Binding(
                                                                get: { showActionSheet && selectedMessage?.id == message.id },
                                                                set: { if !$0 { showActionSheet = false } }
                                                            ),
                                                            titleVisibility: .visible,
                                                        ) {
                                                            Button("Copy") {
                                                                UIPasteboard.general.string = message.text
                                                                selectedMessage = nil
                                                            }
                                                            
                                                            Button("Reply") {
                                                                replyingToMessage = message
                                                                isTextFieldFocused = true
                                                                selectedMessage = nil
                                                            }
                                                            
                                                            if message.sender?.id != userID {
                                                                Button(message.likedBy.isEmpty ? "Like" : "Unlike") {
                                                                    likeMessage(messageID: message.id)
                                                                    selectedMessage = nil
                                                                }
                                                            }
                                                            
                                                            Button("Cancel", role: .cancel) {
                                                                selectedMessage = nil
                                                            }
                                                        }
                                                }
                                            }
                                            
                                            if message.sender?.id != userID {
                                                Spacer()
                                            }
                                        }
                                        .padding(.horizontal)
                                        //MARK: - End of old MessageBubble
                                        .id(message.id)
                                        .onAppear {
                                            if message.id == viewModel.messages.last?.id {
                                                lastMessageIsShowed = true
                                                
                                                print("true now")
                                            }
                                        }
                                        .onDisappear {
                                            if message.id == viewModel.messages.last?.id {
                                                lastMessageIsShowed = false
                                                
                                                print("falseee")
                                            }
                                        }
                                        .overlay(alignment: message.sender?.id == userID ? .topTrailing : .topLeading) {
                                            if !message.likedBy.isEmpty {
                                                Image(systemName: "heart.fill")
                                                    .foregroundColor(.red)
                                                    .font(.title3)
                                                    .offset(x: message.sender?.id == userID ? -5 : 5, y: message.replyingTo == nil ? -5 : 47)
                                            }
                                        }
                                        .onTapGesture(count: 2) {
                                            if message.sender?.id != userID {
                                                likeMessage(messageID: message.id)
                                            }
                                        }
                                        .simultaneousGesture(
                                            LongPressGesture(minimumDuration: 0.1)
                                                .onEnded { _ in
                                                    // When long-pressed, show the action sheet
                                                    selectedMessage = message
                                                    showActionSheet = true
                                                    let impact = UIImpactFeedbackGenerator(style: .medium)
                                                    impact.impactOccurred()
                                                }
                                        )
                                        .simultaneousGesture(
                                            DragGesture(coordinateSpace: .global)
                                                .onChanged { value in
                                                    if dragStartTime == nil {
                                                        dragStartTime = Date()
                                                    }
                                                    
                                                    messageBeingDraggedForReplyingID = message.id
                                                    
                                                    if !isDraggingHorizontallyForReply {
                                                        isDraggingHorizontallyForReply = abs(value.translation.width) > abs(value.translation.height)
                                                    }
                                                    
                                                    if isDraggingHorizontallyForReply {
                                                        withAnimation{
                                                            dragAmountForReplying = message.sender?.id != userID ? max(min(value.translation.width, 100), 0) : min(max(value.translation.width, -100), 0)
                                                        }
                                                    }
                                                    
                                                    if (value.translation.width >= 100 && message.sender?.id != userID && !alreadyPlayedHapticFeedbackForMessageReply) || (value.translation.width <= -100 && message.sender?.id == userID &&  !alreadyPlayedHapticFeedbackForMessageReply) {
                                                        let duration = Date().timeIntervalSince(dragStartTime ?? Date())
                                                        if duration > 0.15 {
                                                            let impact = UIImpactFeedbackGenerator(style: .medium)
                                                            impact.impactOccurred()
                                                            
                                                            alreadyPlayedHapticFeedbackForMessageReply = true
                                                        }
                                                    }
                                                }
                                                .onEnded { value in
                                                    withAnimation(.interactiveSpring(response: 0, dampingFraction: 0.7, blendDuration: 0.7)) {
                                                        dragAmountForReplying = 0
                                                    }
                                                    
                                                    let duration = Date().timeIntervalSince(dragStartTime ?? Date())
                                                    dragStartTime = nil
                                                    
                                                    if duration > 0.15 {
                                                        if (value.translation.width >= 100 && message.sender?.id != userID) || (value.translation.width <= -100 && message.sender?.id == userID) {
                                                            replyingToMessage = message
                                                            isTextFieldFocused = true
                                                        }
                                                    }
                                                    
                                                    messageBeingDraggedForReplyingID = ""
                                                    isDraggingHorizontallyForReply = false // Reset state
                                                    alreadyPlayedHapticFeedbackForMessageReply = false
                                                }
                                        )
                                        .offset(x: dragAmount)
                                        .offset(x: message.id == messageBeingDraggedForReplyingID ? dragAmountForReplying : 0)
                                        
                                        HStack {
                                            Spacer()
                                            
                                            Text(formattedTime(from: message.time))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .padding(.top, 5)
                                                .padding(.trailing, 10)
                                        }
                                        .opacity(dragAmount < -60 ? 1.0 : 0.0)
                                        
                                        if message.sender?.id == userID {
                                            HStack {
                                                Spacer()
                                                
                                                Image(systemName: "arrowshape.turn.up.left.fill")
                                            }
                                            .padding()
                                            .opacity(dragAmountForReplying <= -100 && messageBeingDraggedForReplyingID == message.id ? 1.0 : 0.0)
                                        }
                                        
                                        else {
                                            HStack {
                                                Image(systemName: "arrowshape.turn.up.left.fill")
                                                
                                                Spacer()
                                            }
                                            .padding()
                                            .opacity(dragAmountForReplying >= 100 && messageBeingDraggedForReplyingID == message.id ? 1.0 : 0.0)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .defaultScrollAnchor(.bottom)
                .onChange(of: viewModel.messages) {
                    // This logic now handles the scrolling
                    guard let newestMessageID = viewModel.messages.last?.id else { return }
                    
                    if !hasScrolledInitially {
                        scrollViewProxy.scrollTo(newestMessageID, anchor: .bottom)
                        hasScrolledInitially = true
                    } else {
                        if lastMessageIsShowed {
                            withAnimation {
                                scrollViewProxy.scrollTo(newestMessageID, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            if let message = replyingToMessage {
                HStack {
                    VStack(alignment: .leading) {
                        if message.sender?.id == userID {
                            Text("Replying to yourself")
                                .font(.caption)
                        }
                        else {
                            if let otherUser = viewModel.otherUser {
                                if otherUser.firstName.isEmpty {
                                    Text("Replying to @\(otherUser.username)")
                                        .font(.caption)
                                }
                                else {
                                    Text("Replying to \(otherUser.firstName)")
                                        .font(.caption)
                                }
                            }
                        }
                        
                        Text(message.text)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button {
                        replyingToMessage = nil
                    } label :{
                        Image(systemName: "x.circle.fill")
                    }
                }
                .padding([.horizontal, .top])
                .background(Color(.systemGray6))
            }
            
            // MARK: - Message Input Field
            HStack {
                if isTextFieldFocused {
                    Button {
                        isTextFieldFocused.toggle()
                    } label: {
                        Image(systemName: "chevron.down")
                    }
                }
                
                TextEditor(text: $newMessageText)
                    .frame(minHeight: 40, maxHeight: 160)
                    .fixedSize(horizontal: false, vertical: true)
                    .cornerRadius(10)
                    .padding(5)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .focused($isTextFieldFocused)
                
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .bold()
                }
                .disabled(newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(Color(.systemGray6))
        }
        .navigationTitle(viewModel.otherUser?.username ?? "Loading...")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(false)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.otherUser?.username ?? "Loading...")
                    .font(.headline)
                    .foregroundColor(.clear)
            }
        }
        .background(
            Color.clear.contentShape(Rectangle()) // Make the whole screen tappable
                .onTapGesture {
                    isTextFieldFocused = false // Dismiss keyboard
                }
        )
        .onTapGesture {
            isTextFieldFocused = false // Dismiss keyboard
        }
        .onAppear {
            NotificationCenter.default.post(name: .hideTabBar, object: nil)
            dataManager.shouldShowTabBar = false
            viewModel.fetchInitialData()
        }
    }
    
    func sendMessage() {
        if let replyingToMessage = replyingToMessage {
            viewModel.sendMessage(text: newMessageText.trimmingCharacters(in: .whitespacesAndNewlines), replyingToMessageID: replyingToMessage.id)
        }
        else {
            viewModel.sendMessage(text: newMessageText.trimmingCharacters(in: .whitespacesAndNewlines), replyingToMessageID: nil)
        }
        newMessageText = ""
        replyingToMessage = nil
    }
    
    func likeMessage(messageID: String) {
        viewModel.likeMessage(id: messageID)
    }
    
    private func date(from string: String) -> Foundation.Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: string)
    }
    
    private func formattedTime(from string: String) -> String {
        guard let date = date(from: string) else { return "-" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a" // or "HH:mm" for 24-hour
        return formatter.string(from: date)
    }
    
    func formattedTimestamp(for date: Foundation.Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        
        // Same day
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "hh:mm a" // 12-hour format with AM/PM
        }
        // Yesterday
        else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = "'Yesterday at' hh:mm a" // 12-hour format with AM/PM
        }
        // Less than 7 days ago but not the same weekday (should show as date)
        else if Date().timeIntervalSince(date) < 7 * 24 * 60 * 60 {
            // Check if it's from the same weekday but not today (if not today, show as date)
            if calendar.isDate(date, equalTo: Date(), toGranularity: .weekday) {
                formatter.dateFormat = "dd MMM 'at' hh:mm a" // Abbreviated month and 12-hour format with AM/PM
            } else {
                formatter.dateFormat = "EEEE 'at' hh:mm a" // Full weekday name and 12-hour format with AM/PM
            }
        }
        // Same year
        else if calendar.isDate(date, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "dd MMM 'at' hh:mm a" // Abbreviated month and 12-hour format with AM/PM
        }
        // Different year
        else {
            formatter.dateFormat = "dd MMM yyyy 'at' hh:mm a" // Abbreviated month and 12-hour format with AM/PM
        }
        
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationView {
        ConversationView(conversationID: "1")
    }
    .onAppear {
        DispatchQueue.main.async {
            let loginData = STARSAPI.LoginInput(username: "mariusss", password: "password")
            
            // 2. Perform the mutation
            Network.shared.apollo.perform(mutation: STARSAPI.LoginMutation(data: loginData)) { result in
                switch result {
                case .success(let graphQLResult):
                    if let user = graphQLResult.data?.loginUser {
                        print("Login successful for user: \(user.username)")
                        
                    } else if let errors = graphQLResult.errors {
                        print("GraphQL errors: \(errors)")
                    }
                    
                case .failure(let error):
                    print("Network error: \(error)")
                }
            }
            
            UserDefaults.standard.set(true, forKey: "userIsLoggedIn")
            UserDefaults.standard.set("1", forKey: "userID")
            UserDefaults.standard.set("mariusss", forKey: "userUsername")
            UserDefaults.standard.set("Marius", forKey: "userDisplayName")
            UserDefaults.standard.set(true, forKey: "userHasPremium")
            UserDefaults.standard.set("he/him", forKey: "userPronouns")
            UserDefaults.standard.set("#0D98BA", forKey: "userAccentColorHex")
            UserDefaults.standard.set(true, forKey: "userIsStaff")
            UserDefaults.standard.set(true, forKey: "userIsSuperuser")
        }
    }
}
