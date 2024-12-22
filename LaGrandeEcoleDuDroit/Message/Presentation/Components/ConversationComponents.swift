import SwiftUI

struct ReadConversationItem: View {
    private let conversationUI: ConversationUI
    private let onClick: () -> Void
    
    @State private var isClicked: Bool = false
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    init(conversationUI: ConversationUI, onClick: @escaping () -> Void) {
        self.conversationUI = conversationUI
        self.onClick = onClick
    }
    
    var body: some View {
        if let lastMessage = conversationUI.lastMessage {
            HStack(alignment: .center) {
                if let profilePictureUrl = conversationUI.interlocutor.profilePictureUrl {
                    ProfilePicture(url: profilePictureUrl, scale: 0.4)
                } else {
                    DefaultProfilePicture(scale: 0.4)
                }
                
                VStack(alignment: .leading, spacing: GedSpacing.verySmall) {
                    HStack {
                        Text(conversationUI.interlocutor.fullName)
                            .font(.titleSmall)
                        
                        Text(elapsedTimeText)
                            .font(.bodyMedium)
                            .foregroundStyle(.textPreview)
                    }
                    
                    Text(lastMessage.content)
                        .foregroundStyle(.textPreview)
                        .font(.bodyMedium)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, GedSpacing.small)
            .background(Color(UIColor.systemBackground))
            .onClick(isClicked: $isClicked, action: onClick)
            .onAppear {
                elapsedTimeText = updateElapsedTimeText(for: lastMessage.date)
            }
            .onChange(of: lastMessage.date) { newDate in
                elapsedTimeText = updateElapsedTimeText(for: newDate)
            }
        }
        else {
            EmptyConversationItem(conversationUI: conversationUI, onClick: onClick)
        }
    }
}

struct UnreadConversationItem:View {
    private var conversationUI: ConversationUI
    private let onClick: () -> Void
    
    @State private var isClicked: Bool = false
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    init(conversationUI: ConversationUI, onClick: @escaping () -> Void) {
        self.conversationUI = conversationUI
        self.onClick = onClick
    }
    
    var body: some View {
        if let lastMessage = conversationUI.lastMessage {
            HStack(alignment: .center) {
                if let profilePictureUrl = conversationUI.interlocutor.profilePictureUrl {
                    ProfilePicture(url: profilePictureUrl, scale: 0.4)
                } else {
                    DefaultProfilePicture(scale: 0.4)
                }
                
                VStack(alignment: .leading, spacing: GedSpacing.verySmall) {
                    HStack {
                        Text(conversationUI.interlocutor.fullName)
                            .font(.titleSmall)
                            .fontWeight(.semibold)
                        
                        Text(elapsedTimeText)
                            .font(.bodyMedium)
                            .foregroundStyle(.black)
                    }
                    
                    Text(lastMessage.content)
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
            .padding(.horizontal)
            .padding(.vertical, GedSpacing.small)
            .background(Color(UIColor.systemBackground))
            .onClick(isClicked: $isClicked, action: onClick)
            .onAppear {
                elapsedTimeText = updateElapsedTimeText(for: lastMessage.date)
            }
            .onChange(of: lastMessage.date) { newDate in
                elapsedTimeText = updateElapsedTimeText(for: newDate)
            }
        } else {
            EmptyConversationItem(conversationUI: conversationUI, onClick: onClick)
        }
    }
}

struct EmptyConversationItem: View {
    private var conversationUI: ConversationUI
    private let onClick: () -> Void
    
    @State private var isClicked: Bool = false
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    init(conversationUI: ConversationUI, onClick: @escaping () -> Void) {
        self.conversationUI = conversationUI
        self.onClick = onClick
    }
    
    var body: some View {
        HStack(alignment: .center) {
            if let profilePictureUrl = conversationUI.interlocutor.profilePictureUrl {
                ProfilePicture(url: profilePictureUrl, scale: 0.4)
            } else {
                DefaultProfilePicture(scale: 0.4)
            }
            
            VStack(alignment: .leading, spacing: GedSpacing.verySmall) {
                HStack {
                    Text(conversationUI.interlocutor.fullName)
                        .font(.titleSmall)
                    
                    Text(elapsedTimeText)
                        .font(.bodyMedium)
                        .foregroundStyle(.textPreview)
                }
                
                Text(getString(gedString: GedString.tap_to_chat))
                    .foregroundStyle(.textPreview)
                    .font(.bodyMedium)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, GedSpacing.small)
        .background(Color(UIColor.systemBackground))
        .onClick(isClicked: $isClicked, action: onClick)
    }
}

private func updateElapsedTimeText(for date: Date) -> String {
      let elapsedTime = GetElapsedTimeUseCase.execute(date: date)
      return getElapsedTimeText(elapsedTime: elapsedTime, date: date)
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
    VStack(alignment: .leading, spacing: 0) {
        ReadConversationItem(
            conversationUI: conversationUIFixture,
            onClick: {}
        )
        
        UnreadConversationItem(
            conversationUI: conversationUIFixture,
            onClick: {}
        )
        
        EmptyConversationItem(
            conversationUI: conversationUIFixture,
            onClick: {}
        )
    }
}
