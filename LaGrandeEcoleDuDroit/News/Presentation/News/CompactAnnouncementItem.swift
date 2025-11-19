import SwiftUI

struct CompactAnnouncementItem: View {
    let announcement: Announcement
    let onClick: () -> Void
    let onOptionClick: () -> Void
    
    private let elapsedTimeText: String
    
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
                    DefaultItem(
                        announcement: announcement,
                        elapsedTimeText: elapsedTimeText,
                        onOptionClick: onOptionClick
                    )
                    .padding(.horizontal)
                    .padding(.vertical, Dimens.smallMediumPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                
            case .publishing:
                PublishingItem(
                    announcement: announcement,
                    elapsedTimeText: elapsedTimeText,
                    onClick: onClick,
                    onOptionClick: onOptionClick
                )
                
            case .error:
                ErrorItem(
                    announcement: announcement,
                    elapsedTimeText: elapsedTimeText,
                    onClick: onClick,
                    onOptionClick: onOptionClick
                )
        }
    }
}

private struct DefaultItem: View {
    let announcement: Announcement
    let elapsedTimeText: String
    let onOptionClick: () -> Void
    
    @State private var isClicked: Bool = false
    
    var body: some View {
        HStack(spacing: Dimens.smallMediumPadding) {
            ProfilePicture(
                url: announcement.author.profilePictureUrl,
                scale: 0.5
            )
            
            VStack(alignment: .leading, spacing: Dimens.extraSmallPadding) {
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
            .frame(maxWidth: .infinity, alignment: .leading)
            
            OptionButton(action: onOptionClick)
                .buttonStyle(.borderless)
        }
    }
}

private struct PublishingItem: View {
    let announcement: Announcement
    let elapsedTimeText: String
    let onClick: () -> Void
    let onOptionClick: () -> Void
    
    @State private var isClicked: Bool = false

    var body: some View {
        Clickable(action: onClick) {
            DefaultItem(
                announcement: announcement,
                elapsedTimeText: elapsedTimeText,
                onOptionClick: onOptionClick
            )
            .opacity(0.5)
            .padding(.horizontal)
            .padding(.vertical, Dimens.smallMediumPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
    }
}

private struct ErrorItem: View {
    let announcement: Announcement
    let elapsedTimeText: String
    let onClick: () -> Void
    let onOptionClick: () -> Void
    
    @State private var isClicked: Bool = false

    var body: some View {
        Clickable(action: onClick) {
            HStack(alignment: .center, spacing: Dimens.smallMediumPadding) {
                Image(systemName: "exclamationmark.circle")
                    .foregroundStyle(.red)
                
                DefaultItem(
                    announcement: announcement,
                    elapsedTimeText: elapsedTimeText,
                    onOptionClick: onOptionClick
                )
            }
            .padding(.horizontal)
            .padding(.vertical, Dimens.smallMediumPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    VStack {
        Clickable(action: {}) {
            DefaultItem(
                announcement: announcementFixture,
                elapsedTimeText: "Now",
                onOptionClick: {}
            )
            .padding()
        }
        
        PublishingItem(
            announcement: announcementFixture,
            elapsedTimeText: "5m",
            onClick: {},
            onOptionClick: {}
        )
        
        ErrorItem(
            announcement: announcementFixture,
            elapsedTimeText: "1h",
            onClick: {},
            onOptionClick: {}
        )
    }
}
