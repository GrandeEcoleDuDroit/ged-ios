import SwiftUI

private let previewTextFont: Font = .callout

struct ConversationItem: View {
    let conversationUi: ConversationUi
    let onClick: () -> Void
    let onLongClick: () -> Void
    private let lastMessage: Message
    private let interlocutor: User
    private let text: String
    private let isNotSender: Bool
    
    init(
        conversationUi: ConversationUi,
        onClick: @escaping () -> Void,
        onLongClick: @escaping () -> Void
    ) {
        self.conversationUi = conversationUi
        self.onClick = onClick
        self.onLongClick = onLongClick
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
            text: text,
            onClick: onClick,
            onLongClick: onLongClick
        )
    }
}

private struct SwitchConversationItem: View {
    let interlocutor: User
    let conversationState: ConversationState
    let lastMessage: Message
    let isUnread: Bool
    let text: String
    let onClick: () -> Void
    let onLongClick: () -> Void
    
    @State private var elapsedTimeText: String
    @State private var loading: Bool
    private let interlocutorName: String

    init(
        interlocutor: User,
        conversationState: ConversationState,
        lastMessage: Message,
        isUnread: Bool,
        text: String,
        onClick: @escaping () -> Void,
        onLongClick: @escaping () -> Void
    ) {
        self.interlocutor = interlocutor
        self.conversationState = conversationState
        self.lastMessage = lastMessage
        self.isUnread = isUnread
        self.text = text
        self.onClick = onClick
        self.onLongClick = onLongClick
        self.elapsedTimeText = updateElapsedTimeText(for: lastMessage.date)
        self.loading = self.conversationState == .creating || self.conversationState == .deleting
        self.interlocutorName = interlocutor.state == .deleted ? stringResource(.deletedUser) : interlocutor.fullName
    }
    
    var body: some View {
        ConversationItemStructure(
            interlocutor: interlocutor,
            onClick: onClick,
            onLongClick: onLongClick
        ) {
            if loading {
                ReadConversationItemContent(
                    interlocutorName: interlocutorName,
                    text: text,
                    elapsedTimeText: elapsedTimeText
                ).opacity(0.5)
            } else {
                if isUnread {
                    UnreadConversationItemContent(
                        interlocutorName: interlocutorName,
                        text: text,
                        elapsedTimeText: elapsedTimeText
                    )
                } else {
                    ReadConversationItemContent(
                        interlocutorName: interlocutorName,
                        text: text,
                        elapsedTimeText: elapsedTimeText
                    )
                }
            }
        }
        .opacity(loading ? 0.5 : 1.0)
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

private struct ConversationItemStructure<Content: View>: View {
    let interlocutor: User
    let onClick: () -> Void
    let onLongClick: () -> Void
    let content: Content

    init(
        interlocutor: User,
        onClick: @escaping () -> Void,
        onLongClick: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.interlocutor = interlocutor
        self.onClick = onClick
        self.onLongClick = onLongClick
        self.content = content()
    }
    
    var body: some View {
        Clickable(action: onClick) {
            HStack(alignment: .center) {
                ProfilePicture(url: interlocutor.profilePictureUrl, scale: 0.45)
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, Dimens.smallMediumPadding)
            .contentShape(Rectangle())
            .onLongPressGesture {
                onLongClick()
            }
        }
    }
}

private struct ReadConversationItemContent: View {
    let interlocutorName: String
    let text: String
    let elapsedTimeText: String
    
    var body: some View {
        DefaultConversationItemContent(
            interlocutorName: interlocutorName,
            text: text,
            elapsedTimeText: elapsedTimeText
        )
    }
}

private struct UnreadConversationItemContent: View {
    let interlocutorName: String
    let text: String
    let elapsedTimeText: String
    
    var body: some View {
        HStack {
            DefaultConversationItemContent(
                interlocutorName: interlocutorName,
                text: text,
                elapsedTimeText: elapsedTimeText,
                textColor: .primary,
                fontWeight: .semibold
            )
            
            Spacer()
            
            Circle()
                .fill(.red)
                .frame(width: 10, height: 10)
        }
    }
}


private struct DefaultConversationItemContent: View {
    let interlocutorName: String
    let text: String
    let elapsedTimeText: String
    var textColor: Color = .textPreview
    var fontWeight: Font.Weight = .regular
    
    var body: some View {
        VStack(alignment: .leading, spacing: Dimens.extraSmallPadding) {
            HStack {
                Text(interlocutorName)
                    .fontWeight(fontWeight)
                    .truncationMode(.tail)
                
                Text(elapsedTimeText)
                    .foregroundStyle(textColor)
                    .font(previewTextFont)
            }
            
            Text(text)
                .fontWeight(fontWeight)
                .foregroundStyle(textColor)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}

private struct EmptyConversationItem: View {
    let interlocutorName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Dimens.extraSmallPadding) {
            Text(interlocutorName)
            
            Text(stringResource(.tapToChat))
                .font(previewTextFont)
                .foregroundStyle(.textPreview)
                .lineLimit(1)
                .truncationMode(.tail)
        }
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
    VStack(alignment: .leading, spacing: 0) {
        SwitchConversationItem(
            interlocutor: userFixture,
            conversationState: .created,
            lastMessage: messageFixture,
            isUnread: false,
            text: messageFixture.content,
            onClick: {},
            onLongClick: {}
        )
        
        SwitchConversationItem(
            interlocutor: userFixture,
            conversationState: .created,
            lastMessage: messageFixture,
            isUnread: true,
            text: messageFixture.content,
            onClick: {},
            onLongClick: {}
        )
        
        SwitchConversationItem(
            interlocutor: userFixture,
            conversationState: .creating,
            lastMessage: messageFixture,
            isUnread: false,
            text: messageFixture.content,
            onClick: {},
            onLongClick: {}
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.background)
}
