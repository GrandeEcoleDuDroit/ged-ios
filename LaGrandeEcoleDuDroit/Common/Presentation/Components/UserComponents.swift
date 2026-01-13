import SwiftUI

struct UserItem<TrailingContent: View>: View {
    let user: User
    let trailingContent: () -> TrailingContent

    init(
        user: User,
        trailingContent: @escaping () -> TrailingContent = { EmptyView() }
    ) {
        self.user = user
        self.trailingContent = trailingContent
    }
    
    var body: some View {
        PlainListItem(
            headlineContent: {
                Text(user.displayedName).lineLimit(2)
            },
            leadingContent: {
                ProfilePicture(
                    url: user.profilePictureUrl,
                    scale: 0.5
                )
            },
            trailingContent: trailingContent
        )
    }
}

#Preview {
    UserItem(
        user: userFixture,
        trailingContent: { Text("Trailing") }
    )
}
