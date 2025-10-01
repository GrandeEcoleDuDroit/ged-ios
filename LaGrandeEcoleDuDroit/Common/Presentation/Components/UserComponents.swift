import SwiftUI

struct UserItem<TrailingContent: View>: View {
    let user: User
    let trailingContent: () -> TrailingContent

    init(
        user: User,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() }
    ) {
        self.user = user
        self.trailingContent = trailingContent
    }
    
    var body: some View {
        HStack(alignment: .center) {
            ProfilePicture(
                url: user.profilePictureUrl,
                scale: 0.5
            )
            Text(user.fullName)
            Spacer()
            trailingContent()
        }
        .padding(.vertical, GedSpacing.small)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    UserItem(user: userFixture)
}
