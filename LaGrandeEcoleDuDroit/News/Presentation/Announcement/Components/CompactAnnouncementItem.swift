import SwiftUI

struct CompactAnnouncementItem: View {
    let announcement: Announcement
    let onClick: () -> Void
    let onOptionClick: () -> Void
    
    private let elapsedTimeText: String
    @State private var isClicked: Bool = false
    
    init(
        announcement: Announcement,
        onClick: @escaping () -> Void,
        onOptionClick: @escaping () -> Void
    ) {
        self.announcement = announcement
        self.onClick = onClick
        self.onOptionClick = onOptionClick
        
        elapsedTimeText = getElapsedTimeText(
            elapsedTime: GetElapsedTimeUseCase.execute(date: announcement.date),
            announcementDate: announcement.date
        )
    }
    
    var body: some View {
        switch (announcement.state) {
            case .published, .draft:
                Clickable(action: onClick) {
                    DefaultAnnouncementItem(
                        announcement: announcement,
                        elapsedTimeText: elapsedTimeText,
                        onOptionClick: onOptionClick
                    )
                    .padding(.horizontal)
                    .padding(.vertical, GedSpacing.small)
                }
                
            case .publishing:
                PublishingAnnouncementItem(
                    announcement: announcement,
                    elapsedTimeText: elapsedTimeText,
                    onClick: onClick,
                    onOptionClick: onOptionClick
                )
                
            case .error:
                ErrorAnnouncementItem(
                    announcement: announcement,
                    elapsedTimeText: elapsedTimeText,
                    onClick: onClick,
                    onOptionClick: onOptionClick
                )
        }
    }
}

private struct DefaultAnnouncementItem: View {
    let announcement: Announcement
    let elapsedTimeText: String
    let onOptionClick: () -> Void
    
    @State private var isClicked: Bool = false
    
    var body: some View {
        HStack(spacing: GedSpacing.smallMedium) {
            ProfilePicture(
                url: announcement.author.profilePictureUrl,
                scale: 0.5
            )
            
            VStack(alignment: .leading, spacing: GedSpacing.extraSmall) {
                HStack {
                    Text(announcement.author.fullName)
                        .font(.titleSmall)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .truncationMode(.tail)
                    
                    Text(elapsedTimeText)
                        .foregroundStyle(.textPreview)
                        .font(.bodySmall)
                }
                
                if let title = announcement.title, !title.isEmpty {
                    Text(title)
                        .foregroundStyle(.textPreview)
                        .font(.bodyMedium)
                        .lineLimit(1)
                        .truncationMode(.tail)
                } else {
                    Text(announcement.content)
                        .foregroundStyle(.textPreview)
                        .font(.bodyMedium)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            
            Spacer()
            
            Button(action: onOptionClick) {
                Image(systemName: "ellipsis")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

private struct PublishingAnnouncementItem: View {
    let announcement: Announcement
    let elapsedTimeText: String
    let onClick: () -> Void
    let onOptionClick: () -> Void
    
    @State private var isClicked: Bool = false

    var body: some View {
        Clickable(action: onClick) {
            DefaultAnnouncementItem(
                announcement: announcement,
                elapsedTimeText: elapsedTimeText,
                onOptionClick: onOptionClick
            )
            .opacity(0.5)
            .padding(.horizontal)
            .padding(.vertical, GedSpacing.small)
        }
    }
}

private struct ErrorAnnouncementItem: View {
    let announcement: Announcement
    let elapsedTimeText: String
    let onClick: () -> Void
    let onOptionClick: () -> Void
    
    @State private var isClicked: Bool = false

    var body: some View {
        Clickable(action: onClick) {
            HStack(alignment: .center, spacing: GedSpacing.smallMedium) {
                Image(systemName: "exclamationmark.circle")
                    .foregroundStyle(.red)
                
                DefaultAnnouncementItem(
                    announcement: announcement,
                    elapsedTimeText: elapsedTimeText,
                    onOptionClick: onOptionClick
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, GedSpacing.small)
        }
    }
}

#Preview {
    VStack {
        Clickable(action: {}) {
            DefaultAnnouncementItem(
                announcement: announcementFixture,
                elapsedTimeText: "Now",
                onOptionClick: {}
            )
            .padding(.horizontal)
            .padding(.vertical, GedSpacing.small)
        }
        
        PublishingAnnouncementItem(
            announcement: announcementFixture,
            elapsedTimeText: "5m",
            onClick: {},
            onOptionClick: {}
        )
        
        ErrorAnnouncementItem(
            announcement: announcementFixture,
            elapsedTimeText: "1h",
            onClick: {},
            onOptionClick: {}
        )
    }
}
