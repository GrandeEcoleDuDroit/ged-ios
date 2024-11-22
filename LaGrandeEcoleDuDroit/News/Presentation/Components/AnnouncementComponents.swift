import SwiftUI

struct TopAnnouncementDetailItem: View {
    @Binding private var announcement: Announcement
    @State private var isClicked: Bool = false
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var announcementElapsedTime: String = ""
    
    init(announcement: Binding<Announcement>) {
        self._announcement = announcement
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
            
            Text(announcementElapsedTime)
                .font(.bodyMedium)
                .foregroundStyle(.textPreview)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 5)
        .onAppear {
            elapsedTime = getElapsedTime(date: announcement.date)
            announcementElapsedTime = getElapsedTimeText(elapsedTime: elapsedTime, announcementDate: announcement.date)
        }
    }
}

struct AnnouncementItemWithContent: View {
    @Binding private var announcement: Announcement
    private let onClick: () -> Void
    @State private var isClicked: Bool = false
    @State private var elapsedTime: ElapsedTime = .now(seconds: 0)
    @State private var announcementElapsedTime: String = ""
    
    init(announcement: Binding<Announcement>, onClick: @escaping () -> Void) {
        self._announcement = announcement
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
                    
                    Text(announcementElapsedTime)
                        .font(.bodyMedium)
                        .foregroundStyle(.textPreview)
                }
                
                Text(announcement.title ?? announcement.content)
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
        .clickable(isClicked: $isClicked, onClick: onClick)
        .onAppear {
            elapsedTime = getElapsedTime(date: announcement.date)
            announcementElapsedTime = getElapsedTimeText(elapsedTime: elapsedTime, announcementDate: announcement.date)
        }
    }
}

private func getElapsedTimeText(elapsedTime: ElapsedTime, announcementDate: Date) -> String {
    switch elapsedTime {
    case .now(_), .minute(_), .hour(_):
        getString(gedString: GedString.today)
    case .day(let days):
        if days == 1 {
            getString(gedString: GedString.yesterday)
        }
        else {
            announcementDate.formatted(.dateTime.year().month().day())
        }
    default:
        announcementDate.formatted(.dateTime.year().month().day())
    }
}

#Preview {
    VStack(spacing: 10) {
        TopAnnouncementDetailItem(announcement: .constant(announcementFixture))
            .padding(.horizontal)
        
        AnnouncementItemWithContent(announcement: .constant(announcementFixture), onClick: {})
    }
}
