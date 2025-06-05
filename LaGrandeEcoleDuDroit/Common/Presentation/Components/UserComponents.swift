import SwiftUI

struct UserItem: View {
    private let user: User
    private let onClick: () -> Void
    @State private var isClicked: Bool = false
    
    init(user: User, onClick: @escaping () -> Void) {
        self.user = user
        self.onClick = onClick
    }
    
    var body: some View {
        HStack(alignment: .center) {
            ProfilePicture(url: user.profilePictureFileName, scale: 0.5)
            
            Text(user.fullName)
                .fontWeight(.medium)
        }
        .padding(.vertical, 5)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onClick(isClicked: $isClicked, action: onClick)
    }
}

#Preview {
    UserItem(user: userFixture, onClick: {})
}
