import SwiftUI

struct AnnouncementHeader: View {
    let announcement: Announcement
    let onOptionClick: () -> Void
    let onAuthorClick: () -> Void
    
    private let elapsedTimeText: String
    
    init(
        announcement: Announcement,
        onOptionClick: @escaping () -> Void,
        onAuthorClick: @escaping () -> Void
    ) {
        self.announcement = announcement
        self.onOptionClick = onOptionClick
        self.onAuthorClick = onAuthorClick
        
        elapsedTimeText = getElapsedTimeText(
            elapsedTime: GetElapsedTimeUseCase.execute(date: announcement.date),
            announcementDate: announcement.date
        )
    }

    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .center, spacing: GedSpacing.small) {
                ProfilePicture(url: announcement.author.profilePictureUrl, scale: 0.4)
                
                Text(announcement.author.fullName)
                    .font(.titleSmall)
                
                Text(elapsedTimeText)
                    .foregroundStyle(.textPreview)
                    .font(.bodySmall)
            }
            .onTapGesture(perform: onAuthorClick)
            
            Spacer()
            
            OptionButton(action: onOptionClick)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    AnnouncementHeader(
        announcement: announcementFixture,
        onOptionClick: {},
        onAuthorClick: {}
    ).padding(.horizontal)
}
