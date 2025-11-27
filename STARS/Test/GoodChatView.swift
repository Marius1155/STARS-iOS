import SwiftUI

struct ChatMessage: View {
    
    let text: String
    
    var body: some View {
        HStack {
            Text(text)
                .foregroundStyle(.white)
                .padding()
                .background(.blue)
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )
                .overlay(alignment: .bottomLeading) {
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.title)
                        .rotationEffect(.degrees(45))
                        .offset(x: -10, y: 10)
                        .foregroundStyle(.blue)
                }
            Spacer()
        }
        .padding(.horizontal)
    }
}



struct Message : Identifiable,Equatable {
    var id: Int
    var text: String
}

struct GoodChatView: View {
    @State private var messages: [Message] = []
    @State private var isLoading = true

    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                LazyVStack {
                    ForEach(messages.reversed(), id: \.id) { message in
                        ChatMessage(text: "\(message.text)")
                            .background {
                                GeometryReader { proxy in
                                    let minY = proxy.frame(in: .scrollView).minY
                                    let isReadyForLoad = abs(minY) <= 0.01 && message == messages.last
                                    Color.clear
                                        .onChange(of: isReadyForLoad) { oldVal, newVal in
                                            if newVal && !isLoading {
                                                isLoading = true
                                                Task { @MainActor in
                                                    await loadMoreData()
                                                    await Task.yield()
                                                    scrollView.scrollTo(message.id, anchor: .top)
                                                    await resetLoadingState()
                                                }
                                            }
                                        }
                                }
                            }
                            .onAppear {
                                if !isLoading && message == messages.first {
                                    isLoading = true
                                    Task {
                                        await loadNewData()

                                        // When new data is appended, the scroll position is
                                        // retained - no need to set it again

                                        await resetLoadingState()
                                    }
                                }
                            }
                    }
                }
            }
            .task { @MainActor in
                await loadNewData()
                if let firstMessageId = messages.first?.id {
                    try? await Task.sleep(for: .milliseconds(10))
                    scrollView.scrollTo(firstMessageId, anchor: .bottom)
                }
                await resetLoadingState()
            }
        }
    }

    @MainActor
    func loadMoreData() async {
        let lastId = messages.last?.id ?? 0
        print("old data > \(lastId)")
        var oldMessages: [Message] = []
        for i in lastId+1...lastId+20 {
            let message = Message(id: i, text: "\(i)")
            oldMessages.append(message)
        }
        messages += oldMessages
    }

    @MainActor
    func loadNewData() async {
        let firstId = messages.first?.id ?? 21
        print("new data < \(firstId)")
        var newMessages: [Message] = []
        for i in firstId-20...firstId-1 {
            let message = Message(id: i, text: "\(i)")
            newMessages.append(message)
        }
        messages.insert(contentsOf: newMessages, at: 0)
    }

    @MainActor
    private func resetLoadingState() async {
        try? await Task.sleep(for: .milliseconds(500))
        isLoading = false
    }
}

#Preview {
    GoodChatView()
}
