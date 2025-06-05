import SwiftUI
import Combine

struct MessageFeed: View {
    let messages: [Message]
    let conversation: Conversation
    let screenWidth: CGFloat

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
                                    date2: messages[index - 1].date
                                )
                            } else {
                                false
                            }
                            
                            let sameDay = if let previousMessage = previousMessage {
                                sameDay(
                                    date1: previousMessage.date,
                                    date2: messages[index - 1].date
                                )
                            } else {
                                false
                            }
                            
                            let displayProfilePicture = !sameTime || isFirstMessage || !sameSender
                            
                            if isFirstMessage || !sameDay {
                                let topPadding = isFirstMessage ? GedSpacing.large : 0
                                
                                Text(formatDate(date: message.date))
                                    .foregroundStyle(.gray)
                                    .padding(.vertical, topPadding)
                                    .font(.footnote)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            
                            GetMessageItem(
                                message: message,
                                interlocutorId: conversation.interlocutor.id,
                                showSeen: showSeenMessage,
                                displayProfilePicture: displayProfilePicture,
                                profilePictureUrl: conversation.interlocutor.profilePictureFileName,
                                screenWidth: screenWidth,
                            )
                            .id(message.id)
                            .messageItemPadding(
                                sameSender: sameSender,
                                sameTime: sameTime,
                                sameDay: sameDay
                            )
                        }
                    }
                    Spacer().frame(height: 4).id("last")
                }
                .rotationEffect(.degrees(180))
                .rotationEffect(.degrees(180))
                .onAppear {
                    proxy.scrollTo("last", anchor: .bottom)
                }
                .onChange(of: messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo("last", anchor: .bottom)
                    }
                }
            }
        }
    }
}

private struct GetMessageItem: View {
    let message: Message
    let interlocutorId: String
    let showSeen: Bool
    let displayProfilePicture: Bool
    let profilePictureUrl: String?
    let screenWidth: CGFloat
    
    var body: some View {
        if message.senderId == interlocutorId {
            ReceiveMessageItem(
                message: message,
                profilePictureUrl: profilePictureUrl,
                displayProfilePicture: displayProfilePicture,
                screenWidth: screenWidth
            )
        } else {
            VStack(alignment: .trailing) {
                SendMessageItem(
                    message: message,
                    showSeen: showSeen,
                    screenWidth: screenWidth
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
