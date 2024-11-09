import SwiftUI

struct AnnouncementDetailView: View {
    @Binding var announcement: Announcement

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: GedSpacing.medium) {
                AnnouncementItem(announcement: $announcement)
                
                Text(announcement.content)
                    .font(.body)
                    .multilineTextAlignment(.leading)
            }
            .navigationTitle(announcement.title ?? "No title")
            .navigationBarTitleDisplayMode(.inline)
            .padding(.horizontal)
        }
    }
}

#Preview {
    AnnouncementDetailView(announcement: .constant(announcementFixture))
}
