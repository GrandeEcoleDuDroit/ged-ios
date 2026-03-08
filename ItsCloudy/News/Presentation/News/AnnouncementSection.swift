import SwiftUI

struct AnnouncementSection: View {
    let announcements: [Announcement]?
    let onAnnouncementClick: (Announcement) -> Void
    let onAnnouncementOptionsClick: (Announcement) -> Void
    let onSeeAllAnnouncementsClick: () -> Void
    let onRefreshAnnouncements: () async -> Void
        
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: DimensResource.smallPadding) {
                SectionTitle(title: stringResource(.announcementSectionTitle))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(
                    stringResource(.seeAll),
                    action: onSeeAllAnnouncementsClick
                )
                .foregroundStyle(.appPrimary)
                .font(.callout)
            }
            .padding(.horizontal)
            
            if let announcements {
                PlainTableView(
                    modifier: PlainTableModifier(
                        backgroundColor: .appBackground,
                        onRefresh: onRefreshAnnouncements
                    ),
                    values: announcements,
                    onRowClick: onAnnouncementClick,
                    emptyContent: {
                        Text(stringResource(.noAnnouncement))
                            .foregroundStyle(.informationText)
                    },
                    content: { announcement in
                        CompactAnnouncementItem(
                            announcement: announcement,
                            onOptionsClick: { onAnnouncementOptionsClick(announcement) }
                        )
                    }
                )
            } else {
                ProgressView()
                    .padding(.top)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }
}

#Preview {
    AnnouncementSection(
        announcements: [],
        onAnnouncementClick: { _ in },
        onAnnouncementOptionsClick: { _ in },
        onSeeAllAnnouncementsClick: {},
        onRefreshAnnouncements: {}
    )
    .background(.appBackground)
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
