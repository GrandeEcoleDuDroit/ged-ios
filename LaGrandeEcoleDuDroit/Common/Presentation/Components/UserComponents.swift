import SwiftUI

struct UserItem: View {
    let user: User
    let onClick: () -> Void
    
    var body: some View {
        Clickable(action: onClick) {
            HStack(alignment: .center) {
                ProfilePicture(
                    url: user.profilePictureUrl,
                    scale: 0.5
                )
                
                Text(user.fullName)
                    .fontWeight(.medium)
            }
            .padding(.vertical, GedSpacing.small)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    UserItem(user: userFixture, onClick: {})
}
