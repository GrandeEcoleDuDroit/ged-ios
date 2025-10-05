import SwiftUI

struct AnnouncementHeader: View {
    let announcement: Announcement
    let onAuthorClick: () -> Void
    
    private let elapsedTimeText: String
    
    init(
        announcement: Announcement,
        onAuthorClick: @escaping () -> Void
    ) {
        self.announcement = announcement
        self.onAuthorClick = onAuthorClick
        
        elapsedTimeText = getElapsedTimeText(
            elapsedTime: GetElapsedTimeUseCase.execute(date: announcement.date),
            announcementDate: announcement.date
        )
    }

    var body: some View {
        HStack(alignment: .center, spacing: GedSpacing.small) {
            ProfilePicture(
                url: announcement.author.profilePictureUrl,
                scale: 0.4
            )
            
            Text(announcement.author.fullName)
                .font(.titleSmall)
            
            Text(elapsedTimeText)
                .foregroundStyle(.textPreview)
                .font(.bodySmall)
        }
        .onTapGesture(perform: onAuthorClick)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    AnnouncementHeader(
        announcement: announcementFixture,
        onAuthorClick: {}
    ).padding(.horizontal)
}
