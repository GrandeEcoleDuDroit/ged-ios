import SwiftUI

private let previewTextFont: Font = .callout

struct ConversationItem: View {
    private let conversationUi: ConversationUi
    private let lastMessage: Message
    private let interlocutor: User
    private let text: String
    private let isNotSender: Bool
    
    init(conversationUi: ConversationUi) {
        self.conversationUi = conversationUi
        self.lastMessage = conversationUi.lastMessage
        self.interlocutor = conversationUi.interlocutor
        self.text = lastMessage.state == .sending ? stringResource(.sending) : lastMessage.content
        self.isNotSender = lastMessage.senderId == interlocutor.id
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
    
    @State private var elapsedTimeText: String
    @State private var loading: Bool
    private let interlocutorName: String

    init(
        interlocutor: User,
        conversationState: ConversationState,
        lastMessage: Message,
        isUnread: Bool,
        text: String
    ) {
        self.interlocutor = interlocutor
        self.conversationState = conversationState
        self.lastMessage = lastMessage
        self.isUnread = isUnread
        self.text = text
        self.elapsedTimeText = updateElapsedTimeText(for: lastMessage.date)
        self.loading = self.conversationState == .creating || self.conversationState == .deleting
        self.interlocutorName = interlocutor.state == .deleted ? stringResource(.deletedUser) : interlocutor.fullName
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
        .onAppear {
            elapsedTimeText = updateElapsedTimeText(for: lastMessage.date)
        }
        .onChange(of: lastMessage.date) { newDate in
            elapsedTimeText = updateElapsedTimeText(for: newDate)
        }
        .onChange(of: conversationState) { newState in
            loading = newState == .creating || newState == .deleting
        }
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
                    Text(interlocutor.fullName)
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
    
private func updateElapsedTimeText(for date: Date) -> String {
    let elapsedTime = GetElapsedTimeUseCase.execute(date: date)
    return getElapsedTimeText(elapsedTime: elapsedTime, date: date)
}

private func getElapsedTimeText(elapsedTime: ElapsedTime, date: Date) -> String {
    switch elapsedTime {
        case .now(_):
            stringResource(.now)
            
        case.minute(let minutes):
            stringResource(.minutesAgoShort, minutes)
            
        case .hour(let hours):
            stringResource(.hoursAgoShort, hours)
            
        case .day(let days):
            stringResource(.daysAgoShort, days)
            
        case .week(let weeks):
            stringResource(.weeksAgoShort, weeks)
            
        default:
            date.formatted(.dateTime.year().month().day())
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
