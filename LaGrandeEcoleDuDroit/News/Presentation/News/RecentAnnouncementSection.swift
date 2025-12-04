import SwiftUI

struct RecentAnnouncementSection: View {
    let announcements: [Announcement]
    let onAnnouncementClick: (String) -> Void
    let onUncreatedAnnouncementClick: (Announcement) -> Void
    let onAnnouncementOptionsClick: (Announcement) -> Void
    let onSeeAllAnnouncementClick: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
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
            
            List {
                if announcements.isEmpty {
                    Text(stringResource(.noAnnouncement))
                        .foregroundStyle(.informationText)
                        .padding()
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(announcements) { announcement in
                        Button(
                            action: {
                                if announcement.state == .published {
                                    onAnnouncementClick(announcement.id)
                                } else {
                                    onUncreatedAnnouncementClick(announcement)
                                }
                            }
                        ) {
                            CompactAnnouncementItem(
                                announcement: announcement,
                                onOptionsClick: { onAnnouncementOptionsClick(announcement) }
                            )
                        }
                        .buttonStyle(ClickStyle())
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .listStyle(.plain)
        }
    }
}

#Preview {
    RecentAnnouncementSection(
        announcements: announcementsFixture,
        onAnnouncementClick: { _ in },
        onUncreatedAnnouncementClick: { _ in },
        onAnnouncementOptionsClick: { _ in },
        onSeeAllAnnouncementClick: {}
    )
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
