import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var conversation: ConversationUI
    @State private var inputFocused: InputField? = nil
    @State private var messages: [Message] = []
    
    init(conversation: ConversationUI) {
        self.conversation = conversation
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(messages, id: \.id) { message in
                                if let index = messages.firstIndex(where: { $0.id == message.id }) {
                                    let isFirstMessage = index == 0
                                    
                                    let isLastMessage = index == messages.count - 1
                                    
                                    let previousSenderId = !isFirstMessage ? messages[index - 1].senderId : ""
                                    
                                    let sameSender = message.senderId == previousSenderId
                                    
                                    let nextSenderId = (index < messages.count - 1) ? messages[index + 1].senderId : ""
                                    
                                    let sameTime = index > 0 ? sameDateTime(
                                        date1: message.date,
                                        date2: messages[index - 1].date
                                    ) : false
                                    
                                    let sameDay = index > 0 ? sameDay(
                                        date1: message.date,
                                        date2: messages[index - 1].date
                                    ) : false
                                    
                                    let displayProfilePicture = !sameTime || message.senderId != nextSenderId && message.senderId == conversation.interlocutor.id
                                    
                                    if isFirstMessage || !sameDay {
                                        Text(formatDate(date: message.date))
                                            .foregroundStyle(.gray)
                                            .padding(.vertical, GedSpacing.large)
                                            .font(.footnote)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                    
                                    GetMessageItem(
                                        message: message,
                                        screenWidth: geometry.size.width,
                                        interlocutorId: conversation.interlocutor.id,
                                        displayProfilePicture: displayProfilePicture,
                                        profilePictureUrl: conversation.interlocutor.profilePictureUrl,
                                        isLastMessage: isLastMessage
                                    )
                                    .messageItemPadding(
                                        sameSender: sameSender,
                                        sameTime: sameTime,
                                        sameDay: sameDay
                                    )
                                }
                            }
                        }
                        .rotationEffect(.degrees(180))
                    }
                    .rotationEffect(.degrees(180))
                    .onReceive(chatViewModel.$messages) {
                        messages = $0.sortedByDate()
                    }
                    .onChange(of: messages.count) { _ in
                        proxy.scrollTo(messages.last?.id)
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
        }
        .navigationBarBackButtonHidden()
    }
}

private struct GetMessageItem: View {
    private let message: Message
    private let screenWidth: CGFloat
    private let interlocutorId: String
    private let displayProfilePicture: Bool
    private let profilePictureUrl: String?
    private let isLastMessage: Bool
    
    init(
        message: Message,
        screenWidth: CGFloat,
        interlocutorId: String,
        displayProfilePicture: Bool,
        profilePictureUrl: String?,
        isLastMessage: Bool
    ) {
        self.message = message
        self.screenWidth = screenWidth
        self.interlocutorId = interlocutorId
        self.displayProfilePicture = displayProfilePicture
        self.profilePictureUrl = profilePictureUrl
        self.isLastMessage = isLastMessage
    }
    
    var body: some View {
        if message.senderId == interlocutorId {
            ReceiveMessageItem(
                text: message.content,
                screenWidth: screenWidth,
                displayProfilePicture: displayProfilePicture,
                profilePictureUrl: profilePictureUrl,
                date: message.date
            )
        } else {
            VStack(alignment: .trailing) {
                SendMessageItem(
                    text: message.content,
                    screenWidth: screenWidth,
                    state: message.state,
                    date: message.date
                )
                
                if message.isRead && isLastMessage {
                    Text(getString(.seen))
                        .foregroundStyle(.gray)
                        .font(.bodyMedium)
                        .padding(.trailing, GedSpacing.smallMedium)
                }
            }
        }
    }
}

private extension View {
    func messageItemPadding(sameSender: Bool, sameTime: Bool, sameDay: Bool) -> some View {
        let smallPadding = sameSender && sameTime
        let mediumPadding = sameSender && !sameTime && sameDay
        let noPadding = !sameDay
        
        return Group {
            if smallPadding {
                self.padding(.top, 2)
            } else if mediumPadding {
                self.padding(.top, GedSpacing.smallMedium)
            } else if noPadding {
                self.padding(.top, 0)
            } else {
                self.padding(.top, GedSpacing.medium)
            }
        }
    }
}

private func sameDateTime(date1: Date, date2: Date) -> Bool {
    let calendar = Calendar.current
    return calendar.isDate(date1, equalTo: date2, toGranularity: .minute)
}

private func sameDay(date1: Date, date2: Date) -> Bool {
    let calendar = Calendar.current
    return calendar.isDate(date1, equalTo: date2, toGranularity: .day)
}

private func formatDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .none
    return dateFormatter.string(from: date)
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
