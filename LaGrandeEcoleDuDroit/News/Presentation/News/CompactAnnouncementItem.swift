import SwiftUI

struct CompactAnnouncementItem: View {
    let announcement: Announcement
    let onOptionsClick: () -> Void

    private var elapsedTimeText: String {
        getElapsedTimeText(date: announcement.date)
    }
    
    var body: some View {
        Group {
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
    
    var content: String {
        if let title = announcement.title, !title.isEmpty {
            title
        } else {
            announcement.content
        }
    }
        
    var body: some View {
        HStack(spacing: Dimens.mediumPadding) {
            ProfilePicture(
                url: announcement.author.profilePictureUrl,
                scale: 0.5
            )
            
            VStack(alignment: .leading, spacing: Dimens.extraSmallPadding) {
                HStack {
                    Text(announcement.author.displayedName)
                        .font(AnnouncementUtilsPresentation.authorNameFont)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    Text(elapsedTimeText)
                        .font(.subheadline)
                        .foregroundStyle(.supportingText)
                }
                
                Text(content)
                    .foregroundStyle(.supportingText)
                    .font(.subheadline)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            OptionsButton(action: onOptionsClick)
                .buttonStyle(.borderless)
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
