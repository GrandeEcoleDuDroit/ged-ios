import SwiftUI

struct ConversationItem: View {
    private let conversationUi: ConversationUi
    private let lastMessage: Message
    private let interlocutor: User
    
    init(conversationUi: ConversationUi) {
        self.conversationUi = conversationUi
        self.lastMessage = conversationUi.lastMessage
        self.interlocutor = conversationUi.interlocutor
    }
    
    private var text: String {
        switch lastMessage.state {
            case .sending: stringResource(.sending)
            case .error: stringResource(.messageFailedToSendError)
            default: lastMessage.content
        }
    }
    
    var body: some View {
        SwitchConversationItem(
            interlocutor: interlocutor,
            conversationState: conversationUi.state,
            lastMessage: lastMessage,
            isUnread: lastMessage.senderId == interlocutor.id && !lastMessage.seen,
            text: text
        )
    }
}

private struct SwitchConversationItem: View {
    let interlocutor: User
    let conversationState: Conversation.ConversationState
    let lastMessage: Message
    let isUnread: Bool
    let text: String
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { _ in
            let elapsedTimeText = getElapsedTimeText(date: lastMessage.date)
            
            switch conversationState {
                case .draft, .creating, .deleting:
                    LoadingConversationItem(
                        interlocutor: interlocutor,
                        text: text,
                        elapsedTimeText: elapsedTimeText
                    )
                    
                case .created:
                    if isUnread {
                        UnreadConversationItem(
                            interlocutor: interlocutor,
                            text: text,
                            elapsedTimeText: elapsedTimeText
                        )
                    } else {
                        DefaultConversationItem(
                            interlocutor: interlocutor,
                            text: text,
                            elapsedTimeText: elapsedTimeText
                        )
                    }
                    
                case .error:
                    ErrorConversationItem(
                        interlocutor: interlocutor,
                        text: text,
                        elapsedTimeText: elapsedTimeText
                    )
            }
        }
    }
}

private struct DefaultConversationItem: View {
    let interlocutor: User
    let text: String
    let elapsedTimeText: String
    
    var body: some View {
        PlainListItem(
            headlineContent: {
                HStack {
                    Text(interlocutor.displayedName)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(elapsedTimeText)
                        .font(.subheadline)
                        .foregroundStyle(.supportingText)
                }
            },
            leadingContent: {
                ProfilePicture(
                    url: interlocutor.profilePictureUrl,
                    scale: 0.5
                )
            },
            supportingContent: {
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.supportingText)
                    .lineLimit(1)
            }
        )
    }
}

private struct UnreadConversationItem: View {
    let interlocutor: User
    let text: String
    let elapsedTimeText: String
    
    var body: some View {
        PlainListItem(
            headlineContent: {
                HStack {
                    Text(interlocutor.displayedName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    Text(elapsedTimeText)
                        .font(.subheadline)
                }
            },
            leadingContent: {
                ProfilePicture(
                    url: interlocutor.profilePictureUrl,
                    scale: 0.5
                )
            },
            trailingContent: {
                Circle()
                    .fill(.red)
                    .frame(width: 10, height: 10)
            },
            supportingContent: {
                Text(text)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
        )
    }
}

private struct LoadingConversationItem: View {
    let interlocutor: User
    let text: String
    let elapsedTimeText: String
    var textColor: Color = .supportingText
    var fontWeight: Font.Weight = .regular
    
    var body: some View {
        DefaultConversationItem(
            interlocutor: interlocutor,
            text: text,
            elapsedTimeText: elapsedTimeText
        ).opacity(0.5)
    }
}

private struct ErrorConversationItem: View {
    let interlocutor: User
    let text: String
    let elapsedTimeText: String
    
    var body: some View {
        PlainListItem(
            headlineContent: {
                HStack {
                    Text(interlocutor.displayedName)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(elapsedTimeText)
                        .font(.subheadline)
                        .foregroundStyle(.supportingText)
                }
            },
            leadingContent: {
                HStack(spacing: Dimens.mediumPadding) {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundStyle(.red)
                    
                    ProfilePicture(
                        url: interlocutor.profilePictureUrl,
                        scale: 0.5
                    )
                }
            },
            supportingContent: {
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.supportingText)
                    .lineLimit(1)
            }
        )
    }
}
    
#Preview {
    DefaultConversationItem(
        interlocutor: userFixture,
        text: "Read message",
        elapsedTimeText: "Now"
    )
    
    UnreadConversationItem(
        interlocutor: userFixture,
        text: "Unread message",
        elapsedTimeText: "Now"
    )
    
    LoadingConversationItem(
        interlocutor: userFixture,
        text: "Loading..",
        elapsedTimeText: "Now"
    )
    
    ErrorConversationItem(
        interlocutor: userFixture,
        text: "Error conversation",
        elapsedTimeText: "Now"
    )
}
