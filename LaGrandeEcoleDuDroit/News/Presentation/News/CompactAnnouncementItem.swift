import SwiftUI

struct CompactAnnouncementItem: View {
    let announcement: Announcement
    let onOptionsClick: () -> Void
    
    init(
        announcement: Announcement,
        onOptionsClick: @escaping () -> Void
    ) {
        self.announcement = announcement
        self.onOptionsClick = onOptionsClick
    }

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
        
    var body: some View {
        PlainListItem(
            headlineContent: {
                HeadlineContent(
                    authorFullName: announcement.author.fullName,
                    elapsedTimeText: elapsedTimeText
                )
            },
            leadingContent: { LeadingContent(profilePictureUrl: announcement.author.profilePictureUrl) },
            trailingContent: { TrailingContent(onOptionsClick: onOptionsClick) },
            supportingContent: {
                SupportingContent(
                    title: announcement.title,
                    content: announcement.content
                )
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
    
    var body: some View {
        PlainListItem(
            headlineContent: {
                HeadlineContent(
                    authorFullName: announcement.author.fullName,
                    elapsedTimeText: elapsedTimeText
                )
            },
            leadingContent: {
                HStack(spacing: Dimens.smallMediumPadding) {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundStyle(.red)
                    
                    LeadingContent(profilePictureUrl: announcement.author.profilePictureUrl)
                }
            },
            trailingContent: { TrailingContent(onOptionsClick: onOptionsClick) },
            supportingContent: {
                SupportingContent(
                    title: announcement.title,
                    content: announcement.content
                )
            }
        )
    }
}

private struct HeadlineContent: View {
    let authorFullName: String
    let elapsedTimeText: String
    
    var body: some View {
        HStack {
            Text(authorFullName)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Text(elapsedTimeText)
                .foregroundStyle(.supportingText)
                .font(.bodySmall)
        }
    }
}

private struct LeadingContent: View {
    let profilePictureUrl: String?
    
    var body: some View {
        ProfilePicture(
            url: profilePictureUrl,
            scale: 0.5
        )
    }
}

private struct TrailingContent: View {
    let onOptionsClick: () -> Void
    
    var body: some View {
        OptionsButton(action: onOptionsClick)
    }
}

private struct SupportingContent: View {
    let title: String?
    let content: String
    
    var body: some View {
        if let title, !title.isEmpty {
            Text(title)
                .foregroundStyle(.supportingText)
                .font(.bodyMedium)
                .lineLimit(1)
        } else {
            Text(content)
                .foregroundStyle(.supportingText)
                .font(.bodyMedium)
                .lineLimit(1)
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
