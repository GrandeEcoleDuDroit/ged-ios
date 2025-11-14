import SwiftUI

struct UserItem<TrailingContent: View>: View {
    let user: User
    let trailingContent: () -> TrailingContent
    private let userName: String

    init(
        user: User,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() }
    ) {
        self.user = user
        self.trailingContent = trailingContent
        self.userName = user.state == .deleted ? getString(.deletedUser) : user.fullName
    }
    
    var body: some View {
        HStack(alignment: .center) {
            HStack {
                ProfilePicture(
                    url: user.profilePictureUrl,
                    scale: 0.5
                )
                Text(userName)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            trailingContent()
        }
        .padding(.vertical, GedSpacing.small)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    UserItem(
        user: userFixture,
        trailingContent: {  Text("Trailing") }
    )
}
