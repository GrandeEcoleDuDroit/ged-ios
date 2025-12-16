import SwiftUI

struct BlockedUserDestination: View {
    let onAccountClick: (User) -> Void
    
    @StateObject private var viewModel = AppMainThreadInjector.shared.resolve(BlockedUsersViewModel.self)
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    
    var body: some View {
        BlockedUsersView(
            blockedUsers: viewModel.uiState.blockedUsers,
            loading: viewModel.uiState.loading,
            onAccountClick: onAccountClick,
            onUnblockClick: viewModel.unblockUser
        )
        .onReceive(viewModel.$event) { event in
            if let errorEvent = event as? ErrorEvent {
                errorMessage = errorEvent.message
                showErrorAlert = true
            }
        }
        .alert(
            errorMessage,
            isPresented: $showErrorAlert,
            actions: {
                Button(stringResource(.ok)) {
                    showErrorAlert = false
                }
            }
        )
    }
}

private struct BlockedUsersView: View {
    let blockedUsers: [User]
    let loading: Bool
    let onAccountClick: (User) -> Void
    let onUnblockClick: (String) -> Void
    
    @State private var showUnblockAlert: Bool = false
    @State private var clickedUser: User?
    @State private var selectedUser: User?

    var body: some View {
        List {
            if blockedUsers.isEmpty {
                Text(stringResource(.noBlockedUser))
                    .foregroundStyle(.informationText)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else {
                ForEach(blockedUsers) { user in
                    UserItem(
                        user: user,
                        trailingContent: {
                            Button(stringResource(.unblock)) {
                                showUnblockAlert = true
                                clickedUser = user
                            }
                            .buttonStyle(.borderless)
                            .foregroundStyle(.gedPrimary)
                            .fontWeight(.medium)
                        }
                    )
                    .contentShape(.rect)
                    .listRowTap(
                        action: { onAccountClick(user) },
                        selectedItem: $selectedUser,
                        value: user
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(selectedUser == user ? Color.click : Color.clear)
                }
            }
        }
        .listStyle(.plain)
        .loading(loading)
        .navigationTitle(stringResource(.blockedUsers))
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            stringResource(.unblockUserAlertMessage),
            isPresented: $showUnblockAlert,
            actions: {
                Button(
                    stringResource(.cancel),
                    role: .cancel,
                    action: { showUnblockAlert = false }
                )
                
                Button(stringResource(.unblock)) {
                    if let clickedUser {
                        onUnblockClick(clickedUser.id)
                    }
                    showUnblockAlert = false
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        BlockedUsersView(
            blockedUsers: usersFixture,
            loading: false,
            onAccountClick: { _ in },
            onUnblockClick: { _ in }
        )
        .background(.profileSectionBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
