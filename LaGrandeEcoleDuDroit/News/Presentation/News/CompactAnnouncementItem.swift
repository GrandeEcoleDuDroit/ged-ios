import SwiftUI

struct CompactAnnouncementItem: View {
    let announcement: Announcement
    let onOptionsClick: () -> Void
    
    private let elapsedTimeText: String
    
    init(
        announcement: Announcement,
        onOptionsClick: @escaping () -> Void
    ) {
        self.announcement = announcement
        self.onOptionsClick = onOptionsClick
        
        elapsedTimeText = getElapsedTimeText(
            elapsedTime: GetElapsedTimeUseCase.execute(date: announcement.date),
            announcementDate: announcement.date
        )
    }
    
    var body: some View {
        ZStack {
            switch (announcement.state) {
                case .published, .draft:
                    DefaultItem(
                        announcement: announcement,
                        elapsedTimeText: elapsedTimeText,
                        onOptionsClick: onOptionsClick
                    )
                    
                case .publishing:
                    PublishingItem(
                        announcement: announcement,
                        elapsedTimeText: elapsedTimeText,
                        onOptionsClick: onOptionsClick
                    )
                    
                case .error:
                    ErrorItem(
                        announcement: announcement,
                        elapsedTimeText: elapsedTimeText,
                        onOptionsClick: onOptionsClick
                    )
            }
        }
        .contentShape(Rectangle())
        .padding(.horizontal)
        .padding(.vertical, Dimens.smallMediumPadding)
    }
}

private struct DefaultItem: View {
    let announcement: Announcement
    let elapsedTimeText: String
    let onOptionsClick: () -> Void
        
    var body: some View {
        HStack(spacing: Dimens.mediumPadding) {
            ProfilePicture(
                url: announcement.author.profilePictureUrl,
                scale: 0.5
            )
            
            VStack(alignment: .leading, spacing: Dimens.extraSmallPadding) {
                HStack {
                    Text(announcement.author.fullName)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text(elapsedTimeText)
                        .foregroundStyle(.supportingText)
                        .font(.bodySmall)
                }
                
                if let title = announcement.title, !title.isEmpty {
                    Text(title)
                        .foregroundStyle(.supportingText)
                        .font(.bodyMedium)
                        .lineLimit(1)
                } else {
                    Text(announcement.content)
                        .foregroundStyle(.supportingText)
                        .font(.bodyMedium)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            OptionsButton(action: onOptionsClick)
        }
    }
}

private struct PublishingItem: View {
    let announcement: Announcement
    let elapsedTimeText: String
    let onOptionsClick: () -> Void
    
    var body: some View {
        DefaultItem(
            announcement: announcement,
            elapsedTimeText: elapsedTimeText,
            onOptionsClick: onOptionsClick
        )
        .opacity(0.5)
    }
}

private struct ErrorItem: View {
    let announcement: Announcement
    let elapsedTimeText: String
    let onOptionsClick: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: Dimens.mediumPadding) {
            Image(systemName: "exclamationmark.circle")
                .foregroundStyle(.red)
            
            DefaultItem(
                announcement: announcement,
                elapsedTimeText: elapsedTimeText,
                onOptionsClick: onOptionsClick
            )
        }
    }
}

#Preview {
    DefaultItem(
        announcement: announcementFixture,
        elapsedTimeText: "Now",
        onOptionsClick: {}
    )
    
    PublishingItem(
        announcement: announcementFixture,
        elapsedTimeText: "5m",
        onOptionsClick: {}
    )
    
    ErrorItem(
        announcement: announcementFixture,
        elapsedTimeText: "1h",
        onOptionsClick: {}
    )
}
