import SwiftUI

struct AnnouncementDetailView: View {
    @Binding var announcement: Announcement

    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            AnnouncementItem(announcement: $announcement)
            
            if let title = announcement.title, !title.isEmpty {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            Text(announcement.content)
                .font(.body)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal)
    }
}

#Preview {
    AnnouncementDetailView(announcement: .constant(announcementFixture))
}
