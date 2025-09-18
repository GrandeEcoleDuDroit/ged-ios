import SwiftUI
import Combine

struct MessageFeed: View {
    let messages: [Message]
    let conversation: Conversation
    let loadMoreMessages: () -> Void
    let onErrorMessageClick: (Message) -> Void
    let onReceivedMessageLongClick: (Message) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(messages, id: \.id) { message in
                        if let index = messages.firstIndex(where: { $0.id == message.id }) {
                            let previousMessage = (index > 0) ? messages[index - 1] : nil
                            let condition = MessageCondition(
                                message: message,
                                interlocutor: conversation.interlocutor,
                                messagesSize: messages.count,
                                index: index,
                                previousMessage: previousMessage
                            )
                            
                            if condition.isFirstMessage() || !condition.sameDay() {
                                Text(formatDate(date: message.date))
                                    .foregroundStyle(.gray)
                                    .padding(.vertical, GedSpacing.large)
                                    .font(.footnote)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            
                            GetMessageItem(
                                message: message,
                                interlocutorId: conversation.interlocutor.id,
                                showSeen: condition.showSeenMessage(),
                                displayProfilePicture: condition.displayProfilePicture(),
                                profilePictureUrl: conversation.interlocutor.profilePictureUrl,
                                onErrorMessageClick: onErrorMessageClick,
                                onLongClick: { onReceivedMessageLongClick(message) }
                            )
                            .messageItemPadding(
                                sameSender: condition.sameSender(),
                                sameTime: condition.sameTime(),
                                sameDay: condition.sameDay()
                            )
                        }
                    }
                }
                .rotationEffect(.degrees(180))
                .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geometry.frame(in: .named("scroll")).origin
                        )
                    }
                )
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    if value.y >= 0 && messages.count >= 20 {
                        loadMoreMessages()
                    }
                }
            }
            .rotationEffect(.degrees(180))
            .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
            .coordinateSpace(name: "scroll")
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
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
    
    var body: some View {
        if message.senderId == interlocutorId {
            ReceiveMessageItem(
                message: message,
                profilePictureUrl: profilePictureUrl,
                displayProfilePicture: displayProfilePicture,
                onLongClick: onLongClick
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
    let message: Message
    let interlocutor: User
    let messagesSize: Int
    let index: Int
    let previousMessage: Message?
    
    func isSender() -> Bool {
        message.senderId != interlocutor.id
    }
    
    func isFirstMessage() -> Bool {
        index == messagesSize - 1
    }
    
    func isLastMessage() -> Bool {
        index == 0
    }
    
    func previousSenderId() -> String {
        previousMessage?.senderId ?? ""
    }
    
    func sameSender() -> Bool {
        message.senderId == previousSenderId()
    }
    
    func showSeenMessage() -> Bool {
        isLastMessage() && isSender() && message.seen
    }
    
    func sameTime() -> Bool {
        if let previousMessage = previousMessage {
            Calendar.current.isDate(
                previousMessage.date,
                equalTo: message.date,
                toGranularity: .minute
            )
        } else {
            false
        }
    }
    
    func sameDay() -> Bool {
        if let previousMessage = previousMessage {
            Calendar.current.isDate(
                previousMessage.date,
                equalTo:  message.date,
                toGranularity: .day
            )
        } else {
            false
        }
    }
    
    func displayProfilePicture() -> Bool {
        !sameTime() || isFirstMessage() || !sameSender()
    }
}
