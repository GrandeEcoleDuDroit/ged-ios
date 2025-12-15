import SwiftUI

struct AnnouncementHeader: View {
    let announcement: Announcement
    let onAuthorClick: () -> Void
    
    private var elapsedTimeText: String {
        getElapsedTimeText(date: announcement.date)
    }

    var body: some View {
        HStack(alignment: .center, spacing: Dimens.smallPadding) {
            HStack {
                ProfilePicture(
                    url: announcement.author.profilePictureUrl,
                    scale: 0.4
                )
                
                Text(announcement.author.displayedName)
                    .font(.titleSmall)
                
                Text(elapsedTimeText)
                    .foregroundStyle(.supportingText)
                    .font(.bodySmall)
            }
            .onTapGesture(perform: onAuthorClick)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    AnnouncementHeader(
        announcement: announcementFixture,
        onAuthorClick: {}
    ).padding(.horizontal)
}
