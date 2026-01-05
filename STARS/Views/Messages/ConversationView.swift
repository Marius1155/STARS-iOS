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
import SDWebImageSwiftUI
import STARSAPI


// This ViewModel will be the "brain" for your ConversationView
@MainActor
class ConversationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var messages: [MessageFragment] = []
    @Published var otherUser: GetConversationQuery.Data.Conversations.Edge.Node.Participants.Edge.Node?
    
    // MARK: - Properties
    private let conversationID: String
    private var subscription: Apollo.Cancellable?
    @AppStorage("userID") private var userID: String = ""
    
    private var pageSize = 30
    private var nextCursor: String? = nil
    @Published var hasNextPageOlder = false
    
    init(conversationID: String) {
        self.conversationID = conversationID
    }
    
    deinit {
        // Cancel the subscription when the view model is deallocated
        subscription?.cancel()
    }
    
    // MARK: - Public Methods
    
    func cancelSubscription() {
        subscription?.cancel()
    }
    
    func fetchInitialData() {
        // Fetch the first page of messages (e.g., the latest 50)
        let query = STARSAPI.GetConversationQuery(
            conversationId: conversationID,
            messagesLast: .some(pageSize),
            messagesBefore: nil
        )
        
        Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
            switch result {
            case .success(let graphQLResult):
                if let conversation = graphQLResult.data?.conversations.edges.first?.node {
                    // Find the other participant in the conversation
                    self.otherUser = conversation.participants.edges.first(where: { $0.node.id != self.userID })?.node
                    
                    self.messages = conversation.messages.edges.compactMap { $0.node.fragments.messageFragment }.reversed()
                    
                    self.nextCursor = conversation.messages.pageInfo.startCursor
                    
                    self.hasNextPageOlder = conversation.messages.pageInfo.hasPreviousPage
                    
                    print(conversation.messages.pageInfo.hasPreviousPage)
                    print(conversation.messages.pageInfo.hasNextPage)
                    print(conversation.messages.pageInfo.startCursor ?? 0)
                    print(conversation.messages.pageInfo.endCursor ?? 0)
                    
                    self.markConversationAsSeenByUser()
                    
                    self.startSubscription()
                }
            case .failure(let error):
                print("Error fetching conversation: \(error)")
            }
        }
    }
    
    func loadOlderMessages() {
        guard let nextCursor = self.nextCursor else { return }
        
        let query = STARSAPI.GetConversationQuery(
            conversationId: conversationID,
            messagesLast: .some(pageSize),
            messagesBefore: .some(nextCursor)
        )
        
        print("hii! we're trynna fetch these messages hereeee")
        
        Network.shared.apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
            switch result {
            case .success(let graphQLResult):
                if let conversation = graphQLResult.data?.conversations.edges.first?.node {
                    let newMessages = conversation.messages.edges.compactMap { $0.node.fragments.messageFragment }.reversed()
                    
                    DispatchQueue.main.async {
                        withAnimation(.bouncy()) {
                            self.messages += newMessages
                        }
                        
                        self.nextCursor = conversation.messages.pageInfo.startCursor
                        
                        self.hasNextPageOlder = conversation.messages.pageInfo.hasPreviousPage
                    }
                }
                
            case .failure(let error):
                print("Error loading older messages: \(error)")
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
    
    func markConversationAsSeenByUser() {
        let mutation = STARSAPI.MarkConversationAsSeenByUserMutation(conversationID: conversationID)
        Network.shared.apollo.perform(mutation: mutation) { result in
            switch result {
            case .success(let graphQLResult):
                if let errors = graphQLResult.errors {
                    print("Error marking conversation as seen: \(errors)")
                }
            case .failure(let error):
                print("Network error marking conversation as seen: \(error)")
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
                        DispatchQueue.main.async {
                            withAnimation(.bouncy()) {
                                self.markConversationAsSeenByUser()
                                
                                self.messages.insert(messageFragment, at: 0)
                            }
                        }
                    case "updated":
                        DispatchQueue.main.async {
                            if let index = self.messages.firstIndex(where: { $0.id == messageFragment.id }) {
                                withAnimation(.bouncy()) {
                                    self.messages[index] = messageFragment
                                }
                            }
                        }
                    default:
                        break
                    }
                    
                } else if let deletedPayload = eventData.asMessageDeletedPayload {
                    DispatchQueue.main.async {
                        let deletedID = deletedPayload.id
                        withAnimation(.bouncy()) {
                            self.messages.removeAll(where: { $0.id == deletedID })
                        }
                    }
                    print("message deleted")
                }
                
            case .failure(let error):
                print("Subscription Error: \(error)")
            }
        }
    }
}

// MARK: - VIEW
struct ConversationView: View {
    @Environment(\.scenePhase) var scenePhase
    
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
    
    @State var dataID: String?
    
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
                ZStack {
                    ScrollView {
                        LazyVStack {
                            ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, message in
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
                                                    .padding(.top, 5)
                                                    
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
                                                                    scrollViewProxy.scrollTo(targetMessage.id, anchor: .bottom)
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
                                                    .padding(.bottom, 5)
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
                                                            Button(message.likedBy.edges.isEmpty ? "Like" : "Unlike") {
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
                                    .onAppear {
                                        if message.id == viewModel.messages.first?.id {
                                            lastMessageIsShowed = true
                                        }
                                    }
                                    .onDisappear {
                                        if message.id == viewModel.messages.first?.id {
                                            lastMessageIsShowed = false
                                        }
                                    }
                                    .overlay(alignment: message.sender?.id == userID ? .topTrailing : .topLeading) {
                                        if !message.likedBy.edges.isEmpty {
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
                                                        dragAmountForReplying = max(min(value.translation.width, 50), 0)
                                                    }
                                                }
                                                
                                                if value.translation.width >= 50 && !alreadyPlayedHapticFeedbackForMessageReply {
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
                                                    if value.translation.width >= 50 {
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
                                    
                                    HStack {
                                        Image(systemName: "arrowshape.turn.up.left.fill")
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .opacity(dragAmountForReplying >= 50 && messageBeingDraggedForReplyingID == message.id ? 1.0 : 0.0)
                                }
                                .id(message.id)
                                
                                if index == viewModel.messages.count - 1 {
                                    if let currentDate = date(from: message.time) {
                                        Text(formattedTimestamp(for: currentDate))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .padding(.vertical, 5)
                                    }
                                } else {
                                    if let currentDate = date(from: message.time),
                                       let previousDate = date(from: viewModel.messages[index + 1].time) {
                                        
                                        if currentDate.timeIntervalSince(previousDate) > 1800 {
                                            Text(formattedTimestamp(for: currentDate))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .padding(.vertical, 5)
                                        }
                                    }
                                }
                            }
                            .rotationEffect(.degrees(180))
                            
                            if viewModel.hasNextPageOlder {
                                ProgressView()
                                    .onAppear {
                                        viewModel.loadOlderMessages()
                                    }
                            }
                        }
                    }
                    .rotationEffect(.degrees(180))
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
                    .scrollIndicators(.hidden)
                    .defaultScrollAnchor(.top)
                    .onChange(of: viewModel.messages) {
                        // This logic now handles the scrolling
                        guard let newestMessageID = viewModel.messages.first?.id else { return }
                        
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
                    
                    if !lastMessageIsShowed {
                        VStack {
                            Spacer()
                            
                            Button {
                                scrollViewProxy.scrollTo(viewModel.messages.first?.id, anchor: .bottom)
                            } label : {
                                if #available(iOS 26.0, *) {
                                    Image(systemName: "arrowshape.down.fill")
                                        .foregroundColor(.primary)
                                        .padding()
                                        .glassEffect()
                                } else {
                                    Image(systemName: "arrowshape.down.fill")
                                        .foregroundColor(.primary)
                                        .padding()
                                }
                            }
                            .padding()
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
                    
                    
                    Button {
                        sendMessage()
                        
                        scrollViewProxy.scrollTo(viewModel.messages.first?.id, anchor: .bottom)
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .bold()
                    }
                    .disabled(newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                .background(Color(.systemGray6))
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
            UserDefaults.standard.set("#0D98BA", forKey: "userCustomSecondaryColor")
            UserDefaults.standard.set(true, forKey: "userIsStaff")
            UserDefaults.standard.set(true, forKey: "userIsSuperuser")
        }
    }
}
