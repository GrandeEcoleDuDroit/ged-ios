import SwiftUI

struct CompactAnnouncementItem: View {
    let announcement: Announcement
    let onOptionClick: () -> Void
    
    private let elapsedTimeText: String
    
    init(
        announcement: Announcement,
        onOptionClick: @escaping () -> Void
    ) {
        self.announcement = announcement
        self.onOptionClick = onOptionClick
        
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
                        onOptionClick: onOptionClick
                    )
                    
                case .publishing:
                    PublishingItem(
                        announcement: announcement,
                        elapsedTimeText: elapsedTimeText,
                        onOptionClick: onOptionClick
                    )
                    
                case .error:
                    ErrorItem(
                        announcement: announcement,
                        elapsedTimeText: elapsedTimeText,
                        onOptionClick: onOptionClick
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
    let onOptionClick: () -> Void
        
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
                        .foregroundStyle(.textPreview)
                        .font(.bodySmall)
                }
                
                if let title = announcement.title, !title.isEmpty {
                    Text(title)
                        .foregroundStyle(.textPreview)
                        .font(.bodyMedium)
                        .lineLimit(1)
                } else {
                    Text(announcement.content)
                        .foregroundStyle(.textPreview)
                        .font(.bodyMedium)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            OptionButton(action: onOptionClick)
                .buttonStyle(.borderless)
        }
    }
}

private struct PublishingItem: View {
    let announcement: Announcement
    let elapsedTimeText: String
    let onOptionClick: () -> Void
    
    var body: some View {
        DefaultItem(
            announcement: announcement,
            elapsedTimeText: elapsedTimeText,
            onOptionClick: onOptionClick
        )
        .opacity(0.5)
    }
}

private struct ErrorItem: View {
    let announcement: Announcement
    let elapsedTimeText: String
    let onOptionClick: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: Dimens.mediumPadding) {
            Image(systemName: "exclamationmark.circle")
                .foregroundStyle(.red)
            
            DefaultItem(
                announcement: announcement,
                elapsedTimeText: elapsedTimeText,
                onOptionClick: onOptionClick
            )
        }
    }
}

#Preview {
    DefaultItem(
        announcement: announcementFixture,
        elapsedTimeText: "Now",
        onOptionClick: {}
    )
    
    PublishingItem(
        announcement: announcementFixture,
        elapsedTimeText: "5m",
        onOptionClick: {}
    )
    
    ErrorItem(
        announcement: announcementFixture,
        elapsedTimeText: "1h",
        onOptionClick: {}
    )
}
