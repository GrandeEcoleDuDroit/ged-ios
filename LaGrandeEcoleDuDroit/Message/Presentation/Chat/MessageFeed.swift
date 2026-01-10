import SwiftUI
import Combine

struct MessageFeed: View {
    let messages: [Message]
    let conversation: Conversation
    let canLoadMoreMessages: Bool
    let loadMoreMessages: (Int) -> Void
    let newMessagesEventPublisher: AnyPublisher<Bool, Never>
    let onErrorMessageClick: (Message) -> Void
    let onReceivedMessageLongClick: (Message) -> Void
    let onInterlocutorProfilePictureClick: () -> Void
    
    @State private var showNewMessagesIndicator: Bool = false
    @State private var atBottom: Bool = true
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottom) {
                List(Array(messages.enumerated()), id: \.element) { index, message in
                    let previousMessage = index < messages.count - 1 ? messages[index + 1] : nil
                    let messageCondition = MessageCondition(
                        message: message,
                        interlocutor: conversation.interlocutor,
                        messagesCount: messages.count,
                        index: index,
                        previousMessage: previousMessage
                    )
                    
                    MessageListContent(
                        message: message,
                        condition: messageCondition,
                        interlocutor: conversation.interlocutor,
                        onErrorMessageClick: onErrorMessageClick,
                        onReceivedMessageLongClick: onReceivedMessageLongClick,
                        onInterlocutorProfilePictureClick: onInterlocutorProfilePictureClick
                    )
                    .padding(.horizontal)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .onAppear {
                        if message == messages.last &&
                            messages.count >= MessageConstant.loadLimit &&
                            canLoadMoreMessages
                        {
                            loadMoreMessages(index + 1)
                        }
                        
                        if message == messages.first {
                            showNewMessagesIndicator = false
                        }
                        
                        atBottom = message == messages.first
                    }
                    .listRowBackground(Color.clear)
                    .rotationEffect(.degrees(180))
                    .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                    .id(index)
                }
                .scrollDismissesKeyboard(.interactively)
                .rotationEffect(.degrees(180))
                .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                .listStyle(.plain)
                
                if showNewMessagesIndicator {
                    NewMessageIndicator(onClick: { proxy.scrollTo(0) })
                }
            }
        }
        .onReceive(newMessagesEventPublisher) { _ in
            if !atBottom {
                showNewMessagesIndicator = true
            }
        }
    }
}

private struct MessageListContent: View {
    let message: Message
    let condition: MessageCondition
    let interlocutor: User
    let onErrorMessageClick: (Message) -> Void
    let onReceivedMessageLongClick: (Message) -> Void
    let onInterlocutorProfilePictureClick: () -> Void
    
    var body: some View {
        MessageItem(
            message: message,
            interlocutorId: interlocutor.id,
            showSeen: condition.showSeenMessage,
            displayProfilePicture: condition.displayProfilePicture,
            profilePictureUrl: interlocutor.profilePictureUrl,
            onErrorMessageClick: onErrorMessageClick,
            onLongClick: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onReceivedMessageLongClick(message)
            },
            onInterlocutorProfilePictureClick: onInterlocutorProfilePictureClick
        )
        .padding(.top, messageTopPadding)
        
        if condition.isOldestMessage || !condition.sameDay {
            Text(message.date.formatted(date: .long, time: .omitted))
                .foregroundStyle(.gray)
                .padding(.vertical, Dimens.largePadding)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    var messageTopPadding: CGFloat {
        let small = condition.sameSender && condition.sameTime
        let smallMedium = condition.sameSender && !condition.sameTime && condition.sameDay
        let zero = !condition.sameDay
        
        return if small {
            2
        } else if smallMedium {
            Dimens.smallMediumPadding
        } else if zero {
            0
        } else {
            Dimens.mediumPadding
        }
    }
}

private struct MessageItem: View {
    let message: Message
    let interlocutorId: String
    let showSeen: Bool
    let displayProfilePicture: Bool
    let profilePictureUrl: String?
    let onErrorMessageClick: (Message) -> Void
    let onLongClick: () -> Void
    let onInterlocutorProfilePictureClick: () -> Void
    
    var body: some View {
        if message.senderId == interlocutorId {
            ReceiveMessageItem(
                message: message,
                profilePictureUrl: profilePictureUrl,
                displayProfilePicture: displayProfilePicture,
                onLongClick: onLongClick,
                onInterlocutorProfilePictureClick: onInterlocutorProfilePictureClick
            )
        } else {
            VStack(alignment: .trailing) {
                SentMessageItem(
                    message: message,
                    showSeen: showSeen,
                    onClick: { onErrorMessageClick(message) }
                )
            }
        }
    }
}

private struct MessageCondition {
    private let message: Message
    private let interlocutor: User
    private let messagesSize: Int
    private let index: Int
    private let previousMessage: Message?
    
    let isSender: Bool
    let isOldestMessage: Bool
    let previousSenderId: String
    let sameSender: Bool
    let showSeenMessage: Bool
    let sameTime: Bool
    let sameDay: Bool
    let displayProfilePicture: Bool
    
    init(
        message: Message,
        interlocutor: User,
        messagesCount: Int,
        index: Int,
        previousMessage: Message?
    ) {
        self.message = message
        self.interlocutor = interlocutor
        self.messagesSize = messagesCount
        self.index = index
        self.previousMessage = previousMessage
        
        isSender = message.senderId != interlocutor.id
        isOldestMessage = index == messagesCount - 1
        previousSenderId = previousMessage?.senderId ?? ""
        sameSender = message.senderId == previousSenderId
        showSeenMessage = index == 0 && isSender && message.seen
        
        sameTime = if let previousMessage {
            message.date.differenceMinutes(from: previousMessage.date) <= 1
        } else {
            false
        }
        
        sameDay = if let previousMessage {
            Calendar.current.isDate(
                previousMessage.date,
                equalTo:  message.date,
                toGranularity: .day
            )
        } else {
            false
        }
        
        displayProfilePicture = !sameTime || !sameSender
    }
}

#Preview {
    MessageFeed(
        messages: messagesFixture.sorted { $0.date > $1.date },
        conversation: conversationFixture,
        canLoadMoreMessages: true,
        loadMoreMessages: { _ in },
        newMessagesEventPublisher: Empty().eraseToAnyPublisher(),
        onErrorMessageClick: { _ in },
        onReceivedMessageLongClick: { _ in },
        onInterlocutorProfilePictureClick: {}
    )
}
