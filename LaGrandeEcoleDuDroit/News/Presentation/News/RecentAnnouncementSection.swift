import SwiftUI

struct RecentAnnouncementSection: View {
    let announcements: [Announcement]
    let onAnnouncementClick: (String) -> Void
    let onUncreatedAnnouncementClick: (Announcement) -> Void
    let onAnnouncementOptionsClick: (Announcement) -> Void
    let onSeeAllAnnouncementClick: () -> Void
    let onRefreshAnnouncements: () async -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text(stringResource(.recentAnnouncements))
                    .font(.titleMedium)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(
                    stringResource(.seeAll),
                    action: onSeeAllAnnouncementClick
                )
                .foregroundStyle(.gedPrimary)
                .font(.callout)
                .fontWeight(.semibold)
            }
            .padding(.horizontal)
            
            PlainTableView(
                modifier: PlainTableModifier(onRefresh: onRefreshAnnouncements),
                values: announcements,
                onRowClick: { announcement in
                    if announcement.state == .published {
                        onAnnouncementClick(announcement.id)
                    } else {
                        onUncreatedAnnouncementClick(announcement)
                    }
                },
                emptyContent: {
                    Text(stringResource(.noAnnouncement))
                        .padding()
                        .foregroundStyle(.informationText)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            ) { announcement in
                CompactAnnouncementItem(
                    announcement: announcement,
                    onOptionsClick: { onAnnouncementOptionsClick(announcement) }
                )
            }
        }
    }
}

#Preview {
    RecentAnnouncementSection(
        announcements: announcementsFixture,
        onAnnouncementClick: { _ in },
        onUncreatedAnnouncementClick: { _ in },
        onAnnouncementOptionsClick: { _ in },
        onSeeAllAnnouncementClick: {},
        onRefreshAnnouncements: {}
    )
    .background(.appBackground)
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
