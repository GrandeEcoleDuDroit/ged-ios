import SwiftUI

struct ExtendedAnnouncementItem: View {
    let announcement: Announcement
    let onOptionsClick: () -> Void
    let onAuthorClick: () -> Void
    
    var body: some View {
        switch announcement.state {
            case .published, .draft:
                DefaultItem(
                    announcement: announcement,
                    onOptionsClick: onOptionsClick,
                    onAuthorClick: onAuthorClick
                )
                .padding()
                
            case .publishing:
                PublishingItem(
                    announcement: announcement,
                    onOptionsClick: onOptionsClick,
                    onAuthorClick: onAuthorClick
                )
                .padding()
                
            case.error:
                ErrorItem(
                    announcement: announcement,
                    onOptionsClick: onOptionsClick,
                    onAuthorClick: onAuthorClick
                )
                .padding()
        }
    }
}

private struct DefaultItem: View {
    let announcement: Announcement
    let onOptionsClick: () -> Void
    let onAuthorClick: () -> Void
    
    var body: some View {
        VStack(spacing: Dimens.mediumPadding) {
            HStack(spacing: Dimens.mediumPadding) {
                AnnouncementHeader(
                    announcement: announcement,
                    onAuthorClick: onAuthorClick
                )
                
                OptionsButton(action: onOptionsClick)
            }
            
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
    let onOptionsClick: () -> Void
    let onAuthorClick: () -> Void
    
    var body: some View {
        DefaultItem(
            announcement: announcement,
            onOptionsClick: onOptionsClick,
            onAuthorClick: onAuthorClick
        )
        .opacity(0.5)
    }
}

private struct ErrorItem: View {
    let announcement: Announcement
    let onOptionsClick: () -> Void
    let onAuthorClick: () -> Void
    
    var body: some View {
        VStack(spacing: Dimens.mediumPadding) {
            HStack(spacing: Dimens.smallMediumPadding) {
                Image(systemName: "exclamationmark.circle")
                    .foregroundStyle(.red)
                
                HStack(spacing: Dimens.mediumPadding) {
                    AnnouncementHeader(
                        announcement: announcement,
                        onAuthorClick: onAuthorClick
                    )
                    
                    OptionsButton(action: onOptionsClick)
                }
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
    }
}

#Preview {
    ScrollView {
        VStack {
            DefaultItem(
                announcement: announcementFixture,
                onOptionsClick: {},
                onAuthorClick: {}
            )
            .padding()
            
            PublishingItem(
                announcement: announcementFixture,
                onOptionsClick: {},
                onAuthorClick: {}
            )
            .padding()
            
            ErrorItem(
                announcement: announcementFixture,
                onOptionsClick: {},
                onAuthorClick: {}
            )
            .padding()
        }
    }
}
