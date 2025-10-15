import SwiftUI

struct ExtendedAnnouncementItem: View {
    let announcement: Announcement
    let onClick: () -> Void
    let onOptionClick: () -> Void
    let onAuthorClick: () -> Void
    
    var body: some View {
        switch announcement.state {
            case .published, .draft:
                Clickable(action: onClick) {
                    DefaultItem(
                        announcement: announcement,
                        onOptionClick: onOptionClick,
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
                    onOptionClick: onOptionClick,
                    onAuthorClick: onAuthorClick
                )
                
            case.error:
                ErrorItem(
                    announcement: announcement,
                    onClick: onClick,
                    onOptionClick: onOptionClick,
                    onAuthorClick: onAuthorClick
                )
        }
    }
}

private struct DefaultItem: View {
    let announcement: Announcement
    let onOptionClick: () -> Void
    let onAuthorClick: () -> Void
    
    var body: some View {
        VStack(spacing: GedSpacing.medium) {
            AnnouncementHeader(
                announcement: announcement,
                onAuthorClick: onAuthorClick,
                onOptionClick: onOptionClick
            )
            
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
    }
}

private struct PublishingItem: View {
    let announcement: Announcement
    let onClick: () -> Void
    let onOptionClick: () -> Void
    let onAuthorClick: () -> Void
    
    var body: some View {
        Clickable(action: onClick) {
            DefaultItem(
                announcement: announcement,
                onOptionClick: onOptionClick,
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
    let onOptionClick: () -> Void
    let onAuthorClick: () -> Void
    
    var body: some View {
        Clickable(action: onClick) {
            VStack(spacing: GedSpacing.medium) {
                HStack(
                    alignment: .center,
                    spacing: GedSpacing.smallMedium
                ) {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundStyle(.red)
                    
                    AnnouncementHeader(
                        announcement: announcement,
                        onAuthorClick: onAuthorClick,
                        onOptionClick: onOptionClick
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
        onOptionClick: {},
        onAuthorClick: {}
    )
    
    ExtendedAnnouncementItem(
        announcement: announcementFixture.copy { $0.state = .publishing },
        onClick: {},
        onOptionClick: {},
        onAuthorClick: {}
    )
    
    ExtendedAnnouncementItem(
        announcement: announcementFixture.copy { $0.state = .error },
        onClick: {},
        onOptionClick: {},
        onAuthorClick: {}
    )
}
