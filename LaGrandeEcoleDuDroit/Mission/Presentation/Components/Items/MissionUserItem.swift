import SwiftUI

struct MissionUserItem<TrailingContent: View>: View {
    let user: User
    let imageScale: CGFloat
    let showAdminIndicator: Bool
    let trailingContent: TrailingContent
    
    init(
        user: User,
        imageScale: CGFloat = 0.4,
        showAdminIndicator: Bool = true,
        @ViewBuilder trailingContent: () -> TrailingContent = { EmptyView() }
    ) {
        self.user = user
        self.imageScale = imageScale
        self.showAdminIndicator = showAdminIndicator
        self.trailingContent = trailingContent()
    }
    
    var body: some View {
        PlainListItem(
            headlineContent: {
                HStack(spacing: Dimens.smallPadding) {
                    Text(user.fullName)
                        .lineLimit(1)
                    
                    if user.admin && showAdminIndicator {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.gold)
                            .font(.system(size: 14))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            },
            leadingContent: {
                ProfilePicture(
                    url: user.profilePictureUrl,
                    scale: imageScale
                )
            },
            trailingContent: { trailingContent }
        )
    }
}

#Preview {
    MissionUserItem(user: userFixture)
}
