import SwiftUI

struct AnnouncementHeader: View {
    let announcement: Announcement
    let onAuthorClick: () -> Void
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { _ in
            let elapsedTimeText = getElapsedTimeText(date: announcement.date)

            HStack(spacing: DimensResource.smallMediumPadding) {
                ProfilePicture(
                    url: announcement.author.profilePictureUrl,
                    scale: 0.4
                )
                
                Text(announcement.author.displayedName)
                    .font(AnnouncementUtilsPresentation.authorNameFont)
                    .fontWeight(.semibold)
                
                Text(elapsedTimeText)
                    .font(.footnote)
                    .foregroundStyle(.supportingText)
            }
            .onTapGesture(perform: onAuthorClick)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    AnnouncementHeader(
        announcement: announcementFixture,
        onAuthorClick: {}
    ).padding(.horizontal)
}
