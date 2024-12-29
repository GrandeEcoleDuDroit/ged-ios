import SwiftUI

struct UserItem: View {
    private let user: User
    @State private var isClicked: Bool = false
    
    init(user: User) {
        self.user = user
    }
    
    var body: some View {
        HStack(alignment: .center) {
            ProfilePicture(url: user.profilePictureUrl, scale: 0.4)
            
            Text(user.fullName)
                .font(.titleSmall)
        }
        .padding(.vertical, 5)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .clickEffect(isClicked: $isClicked)
    }
}

#Preview {
    UserItem(user: userFixture)
}
