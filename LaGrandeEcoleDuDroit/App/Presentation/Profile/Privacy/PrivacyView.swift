import SwiftUI

struct PrivacyDestination: View {
    private let onBlockedUsersClick: () -> Void
    
    init(onBlockedUsersClick: @escaping () -> Void) {
        self.onBlockedUsersClick = onBlockedUsersClick
    }
    
    var body: some View {
        PrivacyView(onBlockedUsersClick: onBlockedUsersClick)
    }
}

private struct PrivacyView: View {
    private let onBlockedUsersClick: () -> Void
    
    init(onBlockedUsersClick: @escaping () -> Void) {
        self.onBlockedUsersClick = onBlockedUsersClick
    }
    
    var body: some View {
        List {
            MenuItem(
                title: getString(.blockedUsers),
                onClick: onBlockedUsersClick
            )
        }
        .navigationTitle(getString(.privacy))
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .scrollContentBackground(.hidden)
        .background(.listBackground)
    }
}

#Preview {
    NavigationStack {
        PrivacyView(onBlockedUsersClick: {})
            .background(.listBackground)
    }
}
