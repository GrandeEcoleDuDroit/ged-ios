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
                .frame(maxWidth: .infinity, alignment: .leading)
                
            case .publishing:
                PublishingItem(
                    announcement: announcement,
                    onOptionsClick: onOptionsClick,
                    onAuthorClick: onAuthorClick
                )
                
            case.error:
                ErrorItem(
                    announcement: announcement,
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
        VStack(spacing: DimensResource.mediumPadding) {
            HStack {
                AnnouncementHeader(
                    announcement: announcement,
                    onAuthorClick: onAuthorClick,
                )
                
                OptionsButton(action: onOptionsClick)
                    .buttonStyle(.borderless)
            }
            
            if let title = announcement.title, !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Text(announcement.content)
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
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ErrorItem: View {
    let announcement: Announcement
    let onOptionsClick: () -> Void
    let onAuthorClick: () -> Void
    
    var body: some View {
        VStack(spacing: DimensResource.mediumPadding) {
            HStack(alignment: .center, spacing: DimensResource.smallMediumPadding) {
                Image(systemName: "exclamationmark.circle")
                    .foregroundStyle(.red)
                
                AnnouncementHeader(
                    announcement: announcement,
                    onAuthorClick: onAuthorClick
                )
                
                OptionsButton(action: onOptionsClick)
                    .buttonStyle(.borderless)
            }
            
            if let title = announcement.title {
                Text(title)
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Text(announcement.content)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ScrollView {
        VStack {
            ExtendedAnnouncementItem(
                announcement: longAnnouncementFixture,
                onOptionsClick: {},
                onAuthorClick: {}
            )
            
            ExtendedAnnouncementItem(
                announcement: longAnnouncementFixture.copy { $0.state = .publishing },
                onOptionsClick: {},
                onAuthorClick: {}
            )
            
            ExtendedAnnouncementItem(
                announcement: longAnnouncementFixture.copy { $0.state = .error },
                onOptionsClick: {},
                onAuthorClick: {}
            )
        }
    }
}
