import SwiftUI

struct AnnouncementHeader: View {
    let announcement: Announcement
    let onAuthorClick: () -> Void
    let onOptionClick: () -> Void
    
    private let elapsedTimeText: String
    
    init(
        announcement: Announcement,
        onAuthorClick: @escaping () -> Void,
        onOptionClick: @escaping () -> Void
    ) {
        self.announcement = announcement
        self.onAuthorClick = onAuthorClick
        self.onOptionClick = onOptionClick
        
        elapsedTimeText = getElapsedTimeText(
            elapsedTime: GetElapsedTimeUseCase.execute(date: announcement.date),
            announcementDate: announcement.date
        )
    }

    var body: some View {
        HStack(alignment: .center, spacing: GedSpacing.small) {
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
                        
            OptionButton(action: onOptionClick)
                .buttonStyle(.borderless)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    AnnouncementHeader(
        announcement: announcementFixture,
        onAuthorClick: {},
        onOptionClick: {}
    ).padding(.horizontal)
}
