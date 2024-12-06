import SwiftUI

struct ReadConversationItem: View {
    @Binding private var conversation: Conversation
    private let onClick: () -> Void
    @State private var isClicked: Bool = false
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    init(conversation: Binding<Conversation>, onClick: @escaping () -> Void) {
        self._conversation = conversation
        self.onClick = onClick
    }
    
    var body: some View {
        HStack(alignment: .center) {
            if let profilePictureUrl = conversation.interlocutor.profilePictureUrl {
                ProfilePicture(
                    url: profilePictureUrl,
                    scale: 0.4
                )
            } else {
                DefaultProfilePicture(scale: 0.4)
            }
            
            VStack(alignment: .leading, spacing: GedSpacing.verySmall) {
                HStack {
                    Text(conversation.interlocutor.fullName)
                        .font(.titleSmall)
                    
                    Text(elapsedTimeText)
                        .font(.bodyMedium)
                        .foregroundStyle(.textPreview)
                }
                
                Text(conversation.message.content)
                    .foregroundStyle(.textPreview)
                    .font(.bodyMedium)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemBackground))
        .padding(.horizontal)
        .padding(.vertical, 5)
        .onClick(isClicked: $isClicked, action: onClick)
        .onAppear {
            elapsedTime = GetElapsedTimeUseCase.execute(date: conversation.message.date)
            elapsedTimeText = getElapsedTimeText(elapsedTime: elapsedTime, date: conversation.message.date)
        }
    }
}

struct UnreadConversationItem: View {
    @Binding private var conversation: Conversation
    private let onClick: () -> Void
    @State private var isClicked: Bool = false
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    init(conversation: Binding<Conversation>, onClick: @escaping () -> Void) {
        self._conversation = conversation
        self.onClick = onClick
    }
    
    var body: some View {
        HStack(alignment: .center) {
            if let profilePictureUrl = conversation.interlocutor.profilePictureUrl {
                ProfilePicture(
                    url: profilePictureUrl,
                    scale: 0.4
                )
            } else {
                DefaultProfilePicture(scale: 0.4)
            }
            
            VStack(alignment: .leading, spacing: GedSpacing.verySmall) {
                HStack {
                    Text(conversation.interlocutor.fullName)
                        .font(.titleSmall)
                        .fontWeight(.semibold)
                    
                    Text(elapsedTimeText)
                        .font(.bodyMedium)
                        .foregroundStyle(.black)
                }
                
                Text(conversation.message.content)
                    .font(.bodyMedium)
                    .fontWeight(.semibold)
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
        .background(Color(UIColor.systemBackground))
        .padding(.horizontal)
        .padding(.vertical, 5)
        .onClick(isClicked: $isClicked, action: onClick)
        .onAppear {
            elapsedTime = GetElapsedTimeUseCase.execute(date: conversation.message.date)
            elapsedTimeText = getElapsedTimeText(elapsedTime: elapsedTime, date: conversation.message.date)
        }
    }
}


private func getElapsedTimeText(elapsedTime: ElapsedTime, date: Date) -> String {
    switch elapsedTime {
    case .now(_):
        getString(gedString: GedString.now)
    case.minute(let minutes):
        getString(gedString: GedString.minutes_ago_short, minutes)
    case .hour(let hours):
        getString(gedString: GedString.hours_ago_short, hours)
    case .day(let days):
        getString(gedString: GedString.days_ago_short, days)
    case .week(let weeks):
        getString(gedString: GedString.weeks_ago_short, weeks)
    default:
        date.formatted(.dateTime.year().month().day())
    }
}

#Preview {
    VStack(alignment: .leading) {
        ReadConversationItem(
            conversation: .constant(conversationFixture),
            onClick: {}
        )
        
        UnreadConversationItem(
            conversation: .constant(conversationFixture),
            onClick: {}
        )
    }
}
