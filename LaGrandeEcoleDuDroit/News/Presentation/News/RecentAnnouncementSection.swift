import SwiftUI

struct RecentAnnouncementSection: View {
    let announcements: [Announcement]?
    let onAnnouncementClick: (Announcement) -> Void
    let onAnnouncementOptionsClick: (Announcement) -> Void
    let onSeeAllAnnouncementClick: () -> Void
    let onRefreshAnnouncements: () async -> Void
    
    @State private var selectedAnnouncement: Announcement?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: Dimens.smallPadding) {
                SectionTitle(title: stringResource(.recentAnnouncements))
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
            
            List {
                if let announcements {
                    if announcements.isEmpty {
                        Text(stringResource(.noAnnouncement))
                            .foregroundStyle(.informationText)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(announcements) { announcement in
                            CompactAnnouncementItem(
                                announcement: announcement,
                                onOptionsClick: { onAnnouncementOptionsClick(announcement) }
                            )
                            .contentShape(.rect)
                            .listRowTap(
                                value: announcement,
                                selectedItem: $selectedAnnouncement
                            ) {
                                onAnnouncementClick(announcement)
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(selectedAnnouncement == announcement ? Color.click : Color.clear)
                        }
                    }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .refreshable { await onRefreshAnnouncements() }
        }
    }
}

#Preview {
    RecentAnnouncementSection(
        announcements: announcementsFixture,
        onAnnouncementClick: { _ in },
        onAnnouncementOptionsClick: { _ in },
        onSeeAllAnnouncementClick: {},
        onRefreshAnnouncements: {}
    )
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
