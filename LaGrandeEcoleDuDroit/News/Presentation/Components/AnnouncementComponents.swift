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

struct AnnouncementItemWithContent: View {
    private var announcement: Announcement
    @State private var isClicked: Bool = false
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    init(announcement: Announcement) {
        self.announcement = announcement
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
        .clickEffect(isClicked: $isClicked)
        .onAppear {
            elapsedTime = GetElapsedTimeUseCase.execute(date: announcement.date)
            elapsedTimeText = getElapsedTimeText(elapsedTime: elapsedTime, announcementDate: announcement.date)
        }
    }
}

struct LoadingAnnouncementItemWithContent: View {
    private var announcement: Announcement
    @State private var isClicked: Bool = false
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    init(announcement: Announcement) {
        self.announcement = announcement
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
        .clickEffect(isClicked: $isClicked)
        .onAppear {
            elapsedTime = GetElapsedTimeUseCase.execute(date: announcement.date)
            elapsedTimeText = getElapsedTimeText(elapsedTime: elapsedTime, announcementDate: announcement.date)
        }
    }
}

struct ErrorAnnouncementItemWithContent: View {
    private var announcement: Announcement
    @State private var isClicked: Bool = false
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    init(announcement: Announcement) {
        self.announcement = announcement
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
        .clickEffect(isClicked: $isClicked)
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
        TopAnnouncementDetailItem(announcement: announcementFixture)
            .padding(.horizontal)
        
        AnnouncementItemWithContent(announcement: announcementFixture)
        
        LoadingAnnouncementItemWithContent(announcement: announcementFixture)
        
        ErrorAnnouncementItemWithContent(announcement: announcementFixture)
    }
}
