import SwiftUI
import Combine

struct MessageFeed: View {
    let messages: [Message]
    let conversation: Conversation
    let loadMoreMessages: () -> Void
    let onErrorMessageClick: (Message) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(messages, id: \.id) { message in
                        if let index = messages.firstIndex(where: { $0.id == message.id }) {
                            let isSender = message.senderId != conversation.interlocutor.id
                            let isFirstMessage = index == 0
                            let isLastMessage = index == messages.count - 1
                            let previousMessage = (index > 0) ? messages[index - 1] : nil
                            
                            let previousSenderId = previousMessage?.senderId ?? ""
                            let sameSender = message.senderId == previousSenderId
                            let showSeenMessage = isLastMessage && isSender && message.seen
                            
                            let sameTime = if let previousMessage = previousMessage {
                                sameDateTime(
                                    date1: previousMessage.date,
                                    date2: messages[index].date
                                )
                            } else {
                                false
                            }
                            
                            let sameDay = if let previousMessage = previousMessage {
                                sameDay(
                                    date1: previousMessage.date,
                                    date2: messages[index].date
                                )
                            } else {
                                false
                            }
                            
                            let displayProfilePicture = !sameTime || isFirstMessage || !sameSender
                            
                            if isFirstMessage || !sameDay {
                                Text(formatDate(date: message.date))
                                    .foregroundStyle(.gray)
                                    .padding(.vertical, GedSpacing.large)
                                    .font(.footnote)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            
                            GetMessageItem(
                                message: message,
                                interlocutorId: conversation.interlocutor.id,
                                showSeen: showSeenMessage,
                                displayProfilePicture: displayProfilePicture,
                                profilePictureUrl: conversation.interlocutor.profilePictureUrl,
                                onErrorMessageClick: onErrorMessageClick
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
    
    var body: some View {
        if message.senderId == interlocutorId {
            ReceiveMessageItem(
                message: message,
                profilePictureUrl: profilePictureUrl,
                displayProfilePicture: displayProfilePicture
            )
        } else {
            VStack(alignment: .trailing) {
                SendMessageItem(
                    message: message,
                    showSeen: showSeen,
                    onErrorMessageClick: onErrorMessageClick
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

private func sameDateTime(date1: Date, date2: Date) -> Bool {
    Calendar.current.isDate(date1, equalTo: date2, toGranularity: .minute)
}

private func sameDay(date1: Date, date2: Date) -> Bool {
    Calendar.current.isDate(date1, equalTo: date2, toGranularity: .day)
}

private func formatDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .none
    return dateFormatter.string(from: date)
}
