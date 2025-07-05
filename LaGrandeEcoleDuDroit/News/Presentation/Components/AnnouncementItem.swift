import SwiftUI

private let userNameFont: Font = .titleSmall
private let previewTextFont: Font = .bodyMedium
private let elapsedTimeFont: Font = .bodySmall

struct AnnouncementHeader: View {
    let announcement: Announcement
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""

    var body: some View {
        HStack(alignment: .center, spacing: GedSpacing.smallMedium) {
            ProfilePicture(url: announcement.author.profilePictureUrl, scale: 0.4)
            
            Text(announcement.author.fullName)
                .font(userNameFont)
                .fontWeight(.medium)

            Text(elapsedTimeText)
                .foregroundStyle(.textPreview)
                .font(elapsedTimeFont)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            elapsedTime = GetElapsedTimeUseCase.execute(date: announcement.date)
            elapsedTimeText = getElapsedTimeText(elapsedTime: elapsedTime, announcementDate: announcement.date)
        }
    }
}

struct ShortAnnouncementItem: View {
    let announcement: Announcement
    let onClick: () -> Void
    @State private var isClicked: Bool = false
    
    var body: some View {
        switch (announcement.state) {
            case .published, .draft:
                DefaultShortAnnouncementItem(announcement: announcement)
                    .onClick(isClicked: $isClicked, action: onClick)
                    .padding(.horizontal)
                    .padding(.vertical, GedSpacing.small)
            case .publishing:
                PublishingShortAnnouncementItem(announcement: announcement)
                    .onClick(isClicked: $isClicked, action: onClick)
            case .error:
                ErrorShortAnnouncementItem(announcement: announcement)
                    .onClick(isClicked: $isClicked, action: onClick)
        }
    }
}

private struct DefaultShortAnnouncementItem: View {
    let announcement: Announcement
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    var body: some View {
        HStack(alignment: .center, spacing: GedSpacing.smallMedium) {
            ProfilePicture(url: announcement.author.profilePictureUrl, scale: 0.4)
            
            VStack(alignment: .leading, spacing: GedSpacing.extraSmall) {
                HStack {
                    Text(announcement.author.fullName)
                        .font(userNameFont)
                        .fontWeight(.medium)

                    Text(elapsedTimeText)
                        .foregroundStyle(.textPreview)
                        .font(elapsedTimeFont)
                }
                
                if let title = announcement.title, !title.isEmpty {
                    Text(title)
                        .foregroundStyle(.textPreview)
                        .font(previewTextFont)
                        .lineLimit(1)
                        .truncationMode(.tail)
                } else {
                    Text(announcement.content)
                        .foregroundStyle(.textPreview)
                        .font(previewTextFont)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            elapsedTime = GetElapsedTimeUseCase.execute(date: announcement.date)
            elapsedTimeText = getElapsedTimeText(elapsedTime: elapsedTime, announcementDate: announcement.date)
        }
    }
}

private struct PublishingShortAnnouncementItem: View {
    let announcement: Announcement
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""
    
    var body: some View {
        DefaultShortAnnouncementItem(announcement: announcement)
            .opacity(0.5)
            .padding(.horizontal)
            .padding(.vertical, 5)
    }
}

struct ErrorShortAnnouncementItem: View {
    let announcement: Announcement
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var elapsedTimeText: String = ""

    var body: some View {
        HStack(alignment: .center, spacing: GedSpacing.smallMedium) {
            DefaultShortAnnouncementItem(announcement: announcement)
            
            Image(systemName: "exclamationmark.circle")
                .foregroundStyle(.red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 5)
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
            getString(.minutesAgoShort, minutes)
        case .hour(let hours):
            getString(.hoursAgoShort, hours)
        case .day(let days):
            getString(.daysAgoShort, days)
        case .week(let weeks):
            getString(.weeksAgoShort, weeks)
        default:
            announcementDate.formatted(.dateTime.year().month().day())
    }
}

#Preview {
    VStack(spacing: 10) {
        AnnouncementHeader(announcement: announcementFixture).padding(.horizontal)
        
        DefaultShortAnnouncementItem(announcement: announcementFixture)
            .padding(.horizontal)
            .padding(.vertical, 5)
        
        PublishingShortAnnouncementItem(announcement: announcementFixture)
        
        ErrorShortAnnouncementItem(announcement: announcementFixture)
    }
}
