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
            HeaderSection(
                announcement: announcement,
                onAuthorClick: onAuthorClick,
                onOptionsClick: onOptionsClick
            )
            
            if let title = announcement.title, !title.isEmpty {
                TitleSection(title: title)
            }
            
            ContentSection(content: announcement.content)
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
        VStack(spacing: DimensResource.mediumPadding) {
            HStack(spacing: DimensResource.smallMediumPadding) {
                Image(systemName: "exclamationmark.circle")
                    .foregroundStyle(.red)
                
                HeaderSection(
                    announcement: announcement,
                    onAuthorClick: onAuthorClick,
                    onOptionsClick: onOptionsClick
                )
            }
            
            if let title = announcement.title, !title.isEmpty {
                TitleSection(title: title)
            }
            
            ContentSection(content: announcement.content)
        }
    }
}

private struct HeaderSection: View {
    let announcement: Announcement
    let onAuthorClick: () -> Void
    let onOptionsClick: () -> Void
    
    var body: some View {
        HStack(spacing: DimensResource.smallMediumPadding) {
            AnnouncementHeader(
                announcement: announcement,
                onAuthorClick: onAuthorClick,
            )
            
            OptionsButton(action: onOptionsClick)
                .buttonStyle(.borderless)
        }
    }
}

private struct TitleSection: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title3)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}


private struct ContentSection: View {
    let content: String
    
    var body: some View {
        ExpandableText(content)
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
        .padding(.horizontal)
    }
}
