import SwiftUI
import Combine

struct MessageFeed: View {
    let messages: [Message]
    let conversation: Conversation
    let canLoadMoreMessages: Bool
    let loadMoreMessages: (Int) -> Void
    let onErrorMessageClick: (Message) -> Void
    let onReceivedMessageLongClick: (Message) -> Void
    let onInterlocutorProfilePictureClick: () -> Void

    var body: some View {
        List {
            ForEach(Array(messages.enumerated()), id: \.element) { index, message in
                    Content(
                        conversation: conversation,
                        messages: messages,
                        message: message,
                        index: index,
                        onErrorMessageClick: onErrorMessageClick,
                        onReceivedMessageLongClick: onReceivedMessageLongClick,
                        onInterlocutorProfilePictureClick: onInterlocutorProfilePictureClick
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .onAppear {
                        if message == messages.last &&
                            messages.count >= MessageConstant.loadLimit &&
                            canLoadMoreMessages
                        {
                            loadMoreMessages(index + 1)
                            print("Load more messages")
                        }
                    }
            }
            .listRowBackground(Color.background)
            .rotationEffect(.degrees(180))
            .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
        }
        .rotationEffect(.degrees(180))
        .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
        .scrollIndicators(.hidden)
        .listStyle(.plain)
    }
}

private struct Content: View {
    let conversation: Conversation
    let messages: [Message]
    let message: Message
    let index: Int
    let onErrorMessageClick: (Message) -> Void
    let onReceivedMessageLongClick: (Message) -> Void
    let onInterlocutorProfilePictureClick: () -> Void
    
    var body: some View {
        let previousMessage = index < messages.count - 1 ? messages[index + 1] : nil
        let condition = MessageCondition(
            message: message,
            interlocutor: conversation.interlocutor,
            messagesCount: messages.count,
            index: index,
            previousMessage: previousMessage
        )
        
        GetMessageItem(
            message: message,
            interlocutorId: conversation.interlocutor.id,
            showSeen: condition.showSeenMessage,
            displayProfilePicture: condition.displayProfilePicture,
            profilePictureUrl: conversation.interlocutor.profilePictureUrl,
            onErrorMessageClick: onErrorMessageClick,
            onLongClick: { onReceivedMessageLongClick(message) },
            onInterlocutorProfilePictureClick: onInterlocutorProfilePictureClick
        )
        .messageItemPadding(
            sameSender: condition.sameSender,
            sameTime: condition.sameTime,
            sameDay: condition.sameDay
        )
        
        if condition.isOldestMessage || !condition.sameDay {
            Text(formatDate(date: message.date))
                .foregroundStyle(.gray)
                .padding(.vertical, GedSpacing.large)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

private struct GetMessageItem: View {
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

private func formatDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .none
    return dateFormatter.string(from: date)
}

private struct MessageCondition {
    private let message: Message
    private let interlocutor: User
    private let messagesSize: Int
    private let index: Int
    private let previousMessage: Message?
    
    let isSender: Bool
    let isNewestMessage: Bool
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
        isNewestMessage = index == 0
        isOldestMessage = index == messagesCount - 1
        previousSenderId = previousMessage?.senderId ?? ""
        sameSender = message.senderId == previousSenderId
        showSeenMessage = isNewestMessage && isSender && message.seen
        sameTime = if let previousMessage {
            Calendar.current.isDate(
                previousMessage.date,
                equalTo: message.date,
                toGranularity: .minute
            )
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
        displayProfilePicture = !sameTime || isNewestMessage || !sameSender
    }
}

#Preview {
    MessageFeed(
        messages: messagesFixture.sorted { $0.date > $1.date },
        conversation: conversationFixture,
        canLoadMoreMessages: true,
        loadMoreMessages: { _ in },
        onErrorMessageClick: { _ in },
        onReceivedMessageLongClick: { _ in },
        onInterlocutorProfilePictureClick: {}
    )
    .background(Color.background)
}
