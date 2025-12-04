import SwiftUI

struct ExtendedAnnouncementItem: View {
    let announcement: Announcement
    let onClick: () -> Void
    let onOptionsClick: () -> Void
    let onAuthorClick: () -> Void
    
    var body: some View {
        switch announcement.state {
            case .published, .draft:
                Clickable(action: onClick) {
                    DefaultItem(
                        announcement: announcement,
                        onOptionsClick: onOptionsClick,
                        onAuthorClick: onAuthorClick
                    )
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                
            case .publishing:
                PublishingItem(
                    announcement: announcement,
                    onClick: onClick,
                    onOptionsClick: onOptionsClick,
                    onAuthorClick: onAuthorClick
                )
                
            case.error:
                ErrorItem(
                    announcement: announcement,
                    onClick: onClick,
                    onOptionsClick: onOptionsClick,
                    onAuthorClick: onAuthorClick
                )
        }
    }
}

private struct DefaultItem: View {
    let announcement: Announcement
    let onOptionsClick: () -> Void
    let onAuthorClick: () -> Void
    
    var body: some View {
        VStack(spacing: Dimens.mediumPadding) {
            AnnouncementHeader(
                announcement: announcement,
                onAuthorClick: onAuthorClick,
                onOptionsClick: onOptionsClick
            )
            
            if let title = announcement.title, !title.isEmpty {
                Text(title)
                    .font(.titleMedium)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Text(announcement.content)
                .font(.bodyMedium)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct PublishingItem: View {
    let announcement: Announcement
    let onClick: () -> Void
    let onOptionsClick: () -> Void
    let onAuthorClick: () -> Void
    
    var body: some View {
        Clickable(action: onClick) {
            DefaultItem(
                announcement: announcement,
                onOptionsClick: onOptionsClick,
                onAuthorClick: onAuthorClick
            )
            .opacity(0.5)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
    }
}

private struct ErrorItem: View {
    let announcement: Announcement
    let onClick: () -> Void
    let onOptionsClick: () -> Void
    let onAuthorClick: () -> Void
    
    var body: some View {
        Clickable(action: onClick) {
            VStack(spacing: Dimens.mediumPadding) {
                HStack(
                    alignment: .center,
                    spacing: Dimens.smallMediumPadding
                ) {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundStyle(.red)
                    
                    AnnouncementHeader(
                        announcement: announcement,
                        onAuthorClick: onAuthorClick,
                        onOptionsClick: onOptionsClick
                    )
                }
                
                if let title = announcement.title {
                    Text(title)
                        .font(.titleMedium)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Text(announcement.content)
                    .font(.bodyMedium)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    ExtendedAnnouncementItem(
        announcement: announcementFixture,
        onClick: {},
        onOptionsClick: {},
        onAuthorClick: {}
    )
    
    ExtendedAnnouncementItem(
        announcement: announcementFixture.copy { $0.state = .publishing },
        onClick: {},
        onOptionsClick: {},
        onAuthorClick: {}
    )
    
    ExtendedAnnouncementItem(
        announcement: announcementFixture.copy { $0.state = .error },
        onClick: {},
        onOptionsClick: {},
        onAuthorClick: {}
    )
}
