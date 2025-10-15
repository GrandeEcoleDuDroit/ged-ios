import SwiftUI

struct RecentAnnouncementSection: View {
    let announcements: [Announcement]
    let onAnnouncementClick: (String) -> Void
    let onUncreatedAnnouncementClick: (Announcement) -> Void
    let onAnnouncementOptionClick: (Announcement) -> Void
    let onSeeAllAnnouncementClick: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text(getString(.recentAnnouncements))
                    .font(.titleMedium)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(
                    getString(.seeAll),
                    action: onSeeAllAnnouncementClick
                )
                .foregroundStyle(.gedPrimary)
                .font(.callout)
                .fontWeight(.semibold)
            }
            .padding(.horizontal)
            
            List {
                if announcements.isEmpty {
                    Text(getString(.noAnnouncement))
                        .foregroundStyle(.informationText)
                        .padding()
                        .listRowBackground(Color.background)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(announcements) { announcement in
                        CompactAnnouncementItem(
                            announcement: announcement,
                            onClick: {
                                if announcement.state == .published {
                                    onAnnouncementClick(announcement.id)
                                } else {
                                    onUncreatedAnnouncementClick(announcement)
                                }
                            },
                            onOptionClick: { onAnnouncementOptionClick(announcement) }
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                    }
                    .listRowBackground(Color.background)
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
        onAnnouncementOptionClick: { _ in },
        onSeeAllAnnouncementClick: {}
    )
    .background(Color.background)
}
