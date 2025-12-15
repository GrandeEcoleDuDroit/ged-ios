import SwiftUI

private let previewTextFont: Font = .callout

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
        lastMessage.state == .sending ? stringResource(.sending) : lastMessage.content
    }
    
    private var isNotSender: Bool {
        lastMessage.senderId == interlocutor.id
    }
    
    var body: some View {
        SwitchConversationItem(
            interlocutor: interlocutor,
            conversationState: conversationUi.state,
            lastMessage: lastMessage,
            isUnread: isNotSender && !lastMessage.seen,
            text: text
        )
    }
}

private struct SwitchConversationItem: View {
    let interlocutor: User
    let conversationState: ConversationState
    let lastMessage: Message
    let isUnread: Bool
    let text: String
    
    private var loading: Bool {
        conversationState == .creating || conversationState == .deleting
    }
    
    private var elapsedTimeText: String {
        getElapsedTimeText(date: lastMessage.date)
    }
    
    var body: some View {
        ZStack {
            if loading {
                LoadingConversationItem(
                    interlocutor: interlocutor,
                    text: text,
                    elapsedTimeText: elapsedTimeText
                )
            } else {
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
            }
        }
        .padding(.horizontal)
        .padding(.vertical, Dimens.smallMediumPadding)
    }
}

private struct DefaultConversationItem: View {
    let interlocutor: User
    let text: String
    let elapsedTimeText: String
    var textColor: Color = .supportingText
    var fontWeight: Font.Weight = .regular
    
    var body: some View {
        HStack(spacing: Dimens.mediumPadding) {
            ProfilePicture(url: interlocutor.profilePictureUrl, scale: 0.5)
            
            VStack(alignment: .leading, spacing: Dimens.extraSmallPadding) {
                HStack {
                    Text(interlocutor.displayedName)
                        .fontWeight(fontWeight)
                        .lineLimit(1)
                    
                    Text(elapsedTimeText)
                        .foregroundStyle(textColor)
                        .font(.bodySmall)
                }
                
                Text(text)
                    .fontWeight(fontWeight)
                    .foregroundStyle(textColor)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
    
private struct UnreadConversationItem: View {
    let interlocutor: User
    let text: String
    let elapsedTimeText: String
    
    var body: some View {
        HStack {
            DefaultConversationItem(
                interlocutor: interlocutor,
                text: text,
                elapsedTimeText: elapsedTimeText,
                textColor: .primary,
                fontWeight: .semibold
            )
            
            Circle()
                .fill(.red)
                .frame(width: 10, height: 10)
        }
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
}
