import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var conversation: ConversationUI
    @State private var inputFocused: InputField? = nil
    
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
                onSendClick: { chatViewModel.sendMessage() },
                inputFocused: $inputFocused
            )
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
        .onTapGesture { inputFocused = nil }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    Button(action: {
                        navigationCoordinator.popToRoot()
                    }) {
                        Image(systemName: "chevron.backward")
                            .fontWeight(.semibold)
                            .padding(.trailing)
                    }
                    
                    ProfilePicture(url: conversation.interlocutor.profilePictureUrl, scale: 0.4)
                    
                    Text(conversation.interlocutor.fullName)
                        .font(.bodyLarge)
                }
            }
        }
        .onAppear {
            tabBarVisibility.show = false
            chatViewModel.fetchMessages()
        }
        .navigationBarBackButtonHidden()
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

#Preview {
    struct ChatView_Preview: View {
        @StateObject var navigationCoordinator = CommonDependencyInjectionContainer.shared.resolve(NavigationCoordinator.self)
        let tabBarVisibility = CommonDependencyInjectionContainer.shared.resolve(TabBarVisibility.self)
        
        var body: some View {
            NavigationStack(path: $navigationCoordinator.path) {
                ChatView(conversation: conversationUIFixture)
                    .environmentObject(
                        MessageDependencyInjectionContainer.shared.resolveWithMock().resolve(ChatViewModel.self, argument: conversationUIFixture)!
                    )
                    .environmentObject(navigationCoordinator)
                    .environmentObject(tabBarVisibility)
            }
        }
    }
    
    return ChatView_Preview()
}
