import SwiftUI

struct TopAnnouncementDetailItem: View {
    private var announcement: Announcement
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    init(announcement: Announcement) {
        self.announcement = announcement
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: GedSpacing.smallMedium) {
            if let profilePictureUrl = announcement.author.profilePictureUrl {
                ProfilePicture(
                    url: profilePictureUrl,
                    scale: 0.4
                )
            } else {
                DefaultProfilePicture(scale: 0.4)
            }
            
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

struct AnnouncementItemWithContent: View {
    private var announcement: Announcement
    private let onClick: () -> Void
    @State private var isClicked: Bool = false
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    init(announcement: Announcement, onClick: @escaping () -> Void) {
        self.announcement = announcement
        self.onClick = onClick
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: GedSpacing.smallMedium) {
            if let profilePictureUrl = announcement.author.profilePictureUrl {
                ProfilePicture(
                    url: profilePictureUrl,
                    scale: 0.4
                )
            } else {
                DefaultProfilePicture(scale: 0.4)
            }
            
            VStack(alignment: .leading, spacing: GedSpacing.verySmall) {
                HStack {
                    Text(announcement.author.fullName)
                        .font(.titleSmall)
                    
                    Text(elapsedTimeText)
                        .font(.bodyMedium)
                        .foregroundStyle(.textPreview)
                }
                
                if let title = announcement.title, !title.isEmpty {
                    Text(title)
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
        .background(Color(UIColor.systemBackground))
        .onClick(isClicked: $isClicked, action: onClick)
        .onAppear {
            elapsedTime = GetElapsedTimeUseCase.execute(date: announcement.date)
            elapsedTimeText = getElapsedTimeText(elapsedTime: elapsedTime, announcementDate: announcement.date)
        }
    }
}

struct LoadingAnnouncementItemWithContent: View {
    private var announcement: Announcement
    private let onClick: () -> Void
    @State private var isClicked: Bool = false
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    init(announcement: Announcement, onClick: @escaping () -> Void) {
        self.announcement = announcement
        self.onClick = onClick
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: GedSpacing.smallMedium) {
            if let profilePictureUrl = announcement.author.profilePictureUrl {
                ProfilePicture(
                    url: profilePictureUrl,
                    scale: 0.4
                )
            } else {
                DefaultProfilePicture(scale: 0.4)
            }
            
            VStack(alignment: .leading, spacing: GedSpacing.verySmall) {
                HStack {
                    Text(announcement.author.fullName)
                        .font(.titleSmall)
                    
                    Text(elapsedTimeText)
                        .font(.bodyMedium)
                        .foregroundStyle(.textPreview)
                }
                
                Text(announcement.title ?? announcement.content)
                    .foregroundStyle(.textPreview)
                    .font(.bodyMedium)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            
            Spacer()
            
            ProgressView()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemBackground))
        .padding(.horizontal)
        .padding(.vertical, 5)
        .onClick(isClicked: $isClicked, action: onClick)
        .onAppear {
            elapsedTime = GetElapsedTimeUseCase.execute(date: announcement.date)
            elapsedTimeText = getElapsedTimeText(elapsedTime: elapsedTime, announcementDate: announcement.date)
        }
    }
}

struct ErrorAnnouncementItemWithContent: View {
    private var announcement: Announcement
    private let onClick: () -> Void
    @State private var isClicked: Bool = false
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    init(announcement: Announcement, onClick: @escaping () -> Void) {
        self.announcement = announcement
        self.onClick = onClick
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: GedSpacing.smallMedium) {
            if let profilePictureUrl = announcement.author.profilePictureUrl {
                ProfilePicture(
                    url: profilePictureUrl,
                    scale: 0.4
                )
            } else {
                DefaultProfilePicture(scale: 0.4)
            }
            
            VStack(alignment: .leading, spacing: GedSpacing.verySmall) {
                HStack {
                    Text(announcement.author.fullName)
                        .font(.titleSmall)
                    
                    Text(elapsedTimeText)
                        .font(.bodyMedium)
                        .foregroundStyle(.textPreview)
                }
                
                Text(announcement.title ?? announcement.content)
                    .foregroundStyle(.textPreview)
                    .font(.bodyMedium)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            
            Spacer()
            
            Image(systemName: "exclamationmark.circle")
                .foregroundStyle(.red)
                
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemBackground))
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
        getString(gedString: GedString.now)
    case.minute(let minutes):
        getString(gedString: GedString.minutes_ago_long, minutes)
    case .hour(let hours):
        getString(gedString: GedString.hours_ago_long, hours)
    case .day(let days):
        getString(gedString: GedString.days_ago_long, days)
    case .week(let weeks):
        getString(gedString: GedString.weeks_ago_long, weeks)
    default:
        announcementDate.formatted(.dateTime.year().month().day())
    }
}

#Preview {
    VStack(spacing: 10) {
        TopAnnouncementDetailItem(announcement: announcementFixture)
            .padding(.horizontal)
        
        AnnouncementItemWithContent(announcement: announcementFixture, onClick: {})
        
        LoadingAnnouncementItemWithContent(announcement: announcementFixture, onClick: {})
        
        ErrorAnnouncementItemWithContent(announcement: announcementFixture, onClick: {})
    }
}
