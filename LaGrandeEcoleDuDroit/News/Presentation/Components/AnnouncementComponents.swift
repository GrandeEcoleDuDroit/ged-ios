import SwiftUI

struct AnnouncementHeader: View {
    private var announcement: Announcement
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    init(announcement: Announcement) {
        self.announcement = announcement
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: GedSpacing.smallMedium) {
            ProfilePicture(url: announcement.author.profilePictureUrl, scale: 0.4)
            
            Text(announcement.author.fullName)
                .font(.titleSmall)
            
            Text(elapsedTimeText)
                .font(.bodyMedium)
                .foregroundStyle(.textPreview)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            elapsedTime = GetElapsedTimeUseCase.execute(date: announcement.date)
            elapsedTimeText = getElapsedTimeText(elapsedTime: elapsedTime, announcementDate: announcement.date)
        }
    }
}

struct AnnouncementItem: View {
    private var announcement: Announcement
    private let onClick: () -> Void
    @State private var isClicked: Bool = false
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    init(
        announcement: Announcement,
        onClick: @escaping () -> Void
    ) {
        self.announcement = announcement
        self.onClick = onClick
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: GedSpacing.smallMedium) {
            ProfilePicture(url: announcement.author.profilePictureUrl, scale: 0.4)
            
            VStack(alignment: .leading, spacing: GedSpacing.verySmall) {
                HStack {
                    Text(announcement.author.fullName)
                        .font(.titleSmall)
                    
                    Text(elapsedTimeText)
                        .font(.bodyMedium)
                        .foregroundStyle(.textPreview)
                }
                
                if !announcement.title.isEmpty {
                    Text(announcement.title)
                        .foregroundStyle(.textPreview)
                        .font(.bodyMedium)
                        .lineLimit(1)
                        .truncationMode(.tail)
                } else {
                    Text(announcement.content)
                        .foregroundStyle(.textPreview)
                        .font(.bodyMedium)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 5)
        .onClick(isClicked: $isClicked, action: onClick)
        .onAppear {
            elapsedTime = GetElapsedTimeUseCase.execute(date: announcement.date)
            elapsedTimeText = getElapsedTimeText(elapsedTime: elapsedTime, announcementDate: announcement.date)
        }
    }
}

struct SendingAnnouncementItem: View {
    private var announcement: Announcement
    private var onClick: () -> Void
    @State private var isClicked: Bool = false
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    init(
        announcement: Announcement,
        onClick: @escaping () -> Void
    ) {
        self.announcement = announcement
        self.onClick = onClick
    }
    
    var body: some View {
        AnnouncementItem(announcement: announcement, onClick: onClick)
            .opacity(0.5)
    }
}

struct ErrorAnnouncementItem: View {
    private var announcement: Announcement
    private var onClick: () -> Void
    @State private var isClicked: Bool = false
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    init(
        announcement: Announcement,
        onClick: @escaping () -> Void
    ) {
        self.announcement = announcement
        self.onClick = onClick
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: GedSpacing.smallMedium) {
            ProfilePicture(url: announcement.author.profilePictureUrl, scale: 0.4)
            
            VStack(alignment: .leading, spacing: GedSpacing.verySmall) {
                HStack {
                    Text(announcement.author.fullName)
                        .font(.titleSmall)
                    
                    Text(elapsedTimeText)
                        .font(.bodyMedium)
                        .foregroundStyle(.textPreview)
                }
                
                if !announcement.title.isEmpty {
                    Text(announcement.title)
                        .foregroundStyle(.textPreview)
                        .font(.bodyMedium)
                        .lineLimit(1)
                        .truncationMode(.tail)
                } else {
                    Text(announcement.content)
                        .foregroundStyle(.textPreview)
                        .font(.bodyMedium)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            
            Spacer()
            
            Image(systemName: "exclamationmark.circle")
                .foregroundStyle(.red)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 5)
        .onClick(isClicked: $isClicked, action: onClick)
        .onAppear {
            elapsedTime = GetElapsedTimeUseCase.execute(date: announcement.date)
            elapsedTimeText = getElapsedTimeText(elapsedTime: elapsedTime, announcementDate: announcement.date)
        }
    }
}


private func getElapsedTimeText(elapsedTime: ElapsedTime, announcementDate: Date) -> String {
    switch elapsedTime {
        case .now(_):
            getString(.now)
        case.minute(let minutes):
            getString(.minutesAgoLong, minutes)
        case .hour(let hours):
            getString(.hoursAgoLong, hours)
        case .day(let days):
            getString(.daysAgoLong, days)
        case .week(let weeks):
            getString(.weeksAgoLong, weeks)
        default:
            announcementDate.formatted(.dateTime.year().month().day())
    }
}

#Preview {
    VStack(spacing: 10) {
        AnnouncementHeader(announcement: announcementFixture)
            .padding(.horizontal)
        
        AnnouncementItem(announcement: announcementFixture, onClick: {})
        
        SendingAnnouncementItem(announcement: announcementFixture, onClick: {})
        
        ErrorAnnouncementItem(announcement: announcementFixture, onClick: {})
    }
}
