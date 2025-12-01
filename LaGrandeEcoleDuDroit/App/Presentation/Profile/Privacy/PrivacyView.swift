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
            Button(action: onBlockedUsersClick) {
                ListItem(
                    text: Text(stringResource(.blockedUsers))
                )
            }
        }
        .navigationTitle(stringResource(.privacy))
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    NavigationStack {
        PrivacyView(onBlockedUsersClick: {})
            .background(.profileSectionBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
