import SwiftUI

struct RecentAnnouncementSection: View {
    let announcements: [Announcement]
    let onAnnouncementClick: (String) -> Void
    let onUncreatedAnnouncementClick: (Announcement) -> Void
    let onAnnouncementOptionClick: (Announcement) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(getString(.recentAnnouncements))
                .font(.titleMedium)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            ScrollView {
                if announcements.isEmpty {
                    Text(getString(.noAnnouncement))
                        .foregroundStyle(.informationText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .top)
                } else {
                    LazyVStack(spacing: 0) {
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
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    RecentAnnouncementSection(
        announcements: announcementsFixture,
        onAnnouncementClick: { _ in },
        onUncreatedAnnouncementClick: { _ in },
        onAnnouncementOptionClick: { _ in }
    )
    .background(Color.background)
}
