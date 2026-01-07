import SwiftUI

struct CompactAnnouncementItem: View {
    let announcement: Announcement
    let onOptionsClick: () -> Void

    private var elapsedTimeText: String {
        getElapsedTimeText(date: announcement.date)
    }
    
    var body: some View {
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
        PlainListItem(
            headlineContent: {
                HStack {
                    Text(announcement.author.displayedName)
                        .font(AnnouncementUtilsPresentation.authorNameFont)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    Text(elapsedTimeText)
                        .font(.subheadline)
                        .foregroundStyle(.supportingText)
                }
            },
            leadingContent: {
                ProfilePicture(
                    url: announcement.author.profilePictureUrl,
                    scale: 0.5
                )
            },
            trailingContent: {
                OptionsButton(action: onOptionsClick)
                    .buttonStyle(.borderless)
            },
            supportingContent: {
                Text(content)
                    .font(.subheadline)
                    .foregroundStyle(.supportingText)
                    .lineLimit(1)
            }
        )
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
    
    var content: String {
        if let title = announcement.title, !title.isEmpty {
            title
        } else {
            announcement.content
        }
    }
    
    var body: some View {
        PlainListItem(
            headlineContent: {
                HStack {
                    Text(announcement.author.displayedName)
                        .font(AnnouncementUtilsPresentation.authorNameFont)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    Text(elapsedTimeText)
                        .font(.subheadline)
                        .foregroundStyle(.supportingText)
                }
            },
            leadingContent: {
                HStack(alignment: .center, spacing: Dimens.mediumPadding) {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundStyle(.red)
                    
                    ProfilePicture(
                        url: announcement.author.profilePictureUrl,
                        scale: 0.5
                    )
                }
            },
            trailingContent: {
                OptionsButton(action: onOptionsClick)
                    .buttonStyle(.borderless)
            },
            supportingContent: {
                Text(content)
                    .foregroundStyle(.supportingText)
                    .font(.subheadline)
                    .lineLimit(1)
            }
        )
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
