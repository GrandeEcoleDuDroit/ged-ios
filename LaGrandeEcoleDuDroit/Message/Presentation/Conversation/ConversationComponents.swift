import SwiftUI

private let previewTextFont: Font = .callout

struct ReadConversationItem: View {
    let conversation: ConversationUi
    let onClick: () -> Void
    let onLongClick: () -> Void
    
    @State private var isClicked: Bool = false
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    var body: some View {
        HStack(alignment: .center) {
            ProfilePicture(url: conversation.interlocutor.profilePictureFileName, scale: 0.45)
            
            VStack(alignment: .leading, spacing: GedSpacing.extraSmall) {
                HStack {
                    Text(conversation.interlocutor.fullName)
                    
                    Text(elapsedTimeText)
                        .foregroundStyle(.textPreview)
                        .font(previewTextFont)
                }
                
                Text(conversation.lastMessage.content)
                    .foregroundStyle(.textPreview)
                    .font(previewTextFont)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, GedSpacing.smallMedium)
        .contentShape(Rectangle())
        .onClick(isClicked: $isClicked, action: onClick)
        .onLongClick(isClicked: $isClicked, action: onLongClick)
        .onAppear {
            elapsedTimeText = updateElapsedTimeText(for: conversation.lastMessage.date)
        }
        .onChange(of: conversation.lastMessage.date) { newDate in
            elapsedTimeText = updateElapsedTimeText(for: newDate)
        }
    }
}

struct UnreadConversationItem:View {
    let conversation: ConversationUi
    let onClick: () -> Void
    let onLongClick: () -> Void
    
    @State private var isClicked: Bool = false
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    var body: some View {
        HStack(alignment: .center) {
            ProfilePicture(url: conversation.interlocutor.profilePictureFileName, scale: 0.45)
            
            VStack(alignment: .leading, spacing: GedSpacing.extraSmall) {
                HStack {
                    Text(conversation.interlocutor.fullName)
                        .fontWeight(.semibold)
                    
                    Text(elapsedTimeText)
                        .font(previewTextFont)
                        .foregroundStyle(.black)
                }
                
                Text(conversation.lastMessage.content)
                    .fontWeight(.semibold)
                    .font(previewTextFont)
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            
            Spacer()
            
            Circle()
                .fill(.red)
                .frame(width: 10, height: 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, GedSpacing.smallMedium)
        .contentShape(Rectangle())
        .onClick(isClicked: $isClicked, action: onClick)
        .onLongClick(isClicked: $isClicked, action: onLongClick)
        .onAppear {
            elapsedTimeText = updateElapsedTimeText(for: conversation.lastMessage.date)
        }
        .onChange(of: conversation.lastMessage.date) { newDate in
            elapsedTimeText = updateElapsedTimeText(for: newDate)
        }
    }
}

struct EmptyConversationItem: View {
    let conversation: ConversationUi
    let onClick: () -> Void
    let onLongClick: () -> Void
    
    @State private var isClicked: Bool = false
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    var body: some View {
        HStack(alignment: .center) {
            ProfilePicture(url: conversation.interlocutor.profilePictureFileName, scale: 0.45)
            
            VStack(alignment: .leading, spacing: GedSpacing.extraSmall) {
                HStack {
                    Text(conversation.interlocutor.fullName)

                    Text(elapsedTimeText)
                        .font(previewTextFont)
                        .foregroundStyle(.textPreview)
                }
                
                Text(getString(.tapToChat))
                    .font(previewTextFont)
                    .foregroundStyle(.textPreview)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, GedSpacing.smallMedium)
        .contentShape(Rectangle())
        .onClick(isClicked: $isClicked, action: onClick)
        .onLongClick(isClicked: $isClicked, action: onLongClick)
    }
}

private func updateElapsedTimeText(for date: Date) -> String {
    let elapsedTime = GetElapsedTimeUseCase.execute(date: date)
    return getElapsedTimeText(elapsedTime: elapsedTime, date: date)
}

private func getElapsedTimeText(elapsedTime: ElapsedTime, date: Date) -> String {
    switch elapsedTime {
        case .now(_):
            getString(.now)
        case.minute(let minutes):
            getString(.minutesAgoShort, minutes)
        case .hour(let hours):
            getString(.hoursAgoShort, hours)
        case .day(let days):
            getString(.daysAgoShort, days)
        case .week(let weeks):
            getString(.weeksAgoShort, weeks)
        default:
            date.formatted(.dateTime.year().month().day())
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 0) {
        ReadConversationItem(
            conversation: conversationUiFixture,
            onClick: {},
            onLongClick: {}
        )
        
        UnreadConversationItem(
            conversation: conversationUiFixture,
            onClick: {},
            onLongClick: {}
        )
        
        EmptyConversationItem(
            conversation: conversationUiFixture,
            onClick: {},
            onLongClick: {}
        )
    }
}
