import SwiftUI

struct AnnouncementHeader: View {
    let announcement: Announcement
    let onAuthorClick: () -> Void
    let onOptionsClick: () -> Void
    
    private let elapsedTimeText: String
    
    init(
        announcement: Announcement,
        onAuthorClick: @escaping () -> Void,
        onOptionsClick: @escaping () -> Void
    ) {
        self.announcement = announcement
        self.onAuthorClick = onAuthorClick
        self.onOptionsClick = onOptionsClick
        
        elapsedTimeText = getElapsedTimeText(
            elapsedTime: GetElapsedTimeUseCase.execute(date: announcement.date),
            announcementDate: announcement.date
        )
    }

    var body: some View {
        HStack(alignment: .center, spacing: Dimens.smallPadding) {
            HStack {
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
            
            Spacer()
                        
            OptionsButton(action: onOptionsClick)
                .buttonStyle(.borderless)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    AnnouncementHeader(
        announcement: announcementFixture,
        onAuthorClick: {},
        onOptionsClick: {}
    ).padding(.horizontal)
}
