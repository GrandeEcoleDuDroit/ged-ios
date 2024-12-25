import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @State private var conversation: ConversationUI
    
    init(conversation: ConversationUI) {
        self.conversation = conversation
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(chatViewModel.messages, id: \.id) { message in
                                if let index = chatViewModel.messages.firstIndex(where: { $0.id == message.id }) {
                                    let previousSenderId = (index > 0) ? chatViewModel.messages[index - 1].senderId : ""
                                    
                                    if message.senderId == conversation.interlocutor.id {
                                        ReceiveMessageItem(
                                            text: message.content,
                                            screenWidth: geometry.size.width
                                        )
                                        .messageItemPadding(
                                            previousSenderId: previousSenderId,
                                            senderId: message.senderId
                                        )
                                    } else {
                                        SendMessageItem(
                                            text: message.content,
                                            screenWidth: geometry.size.width
                                        )
                                        .messageItemPadding(
                                            previousSenderId: previousSenderId,
                                            senderId: message.senderId
                                        )
                                    }
                                }
                            }
                        }
                        .rotationEffect(.degrees(180))
                    }
                    .rotationEffect(.degrees(180))
                    .onChange(of: chatViewModel.messages.count) { _ in
                        proxy.scrollTo(chatViewModel.messages.last?.id)
                    }
                }
            }
            
            ChatInputField(
                text: $chatViewModel.textToSend,
                onSendClick: { chatViewModel.sendMessage() }
            )
        }
        .padding(.horizontal)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    if let profilePictureUrl = conversation.interlocutor.profilePictureUrl {
                        ProfilePicture(url: profilePictureUrl, scale: 0.4)
                    } else {
                        DefaultProfilePicture(scale: 0.4)
                    }
                    
                    Text(conversation.interlocutor.fullName)
                        .font(.bodyLarge)
                }
            }
        }
        .onAppear {
            chatViewModel.fetchMessages()
        }
    }
}

#Preview {
    NavigationView {
        ChatView(conversation: conversationUIFixture)
            .environmentObject(DependencyContainer.shared.mockChatViewModel)
    }
}

private extension View {
    func messageItemPadding(previousSenderId: String, senderId: String) -> some View {
        Group {
            if previousSenderId == senderId {
                self.padding(.top, GedSpacing.verySmall)
            } else {
                self.padding(.top, GedSpacing.smallMedium)
            }
        }
    }
}
