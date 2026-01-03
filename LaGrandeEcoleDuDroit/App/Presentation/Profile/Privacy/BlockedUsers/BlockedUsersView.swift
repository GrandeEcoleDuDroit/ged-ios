import SwiftUI

struct BlockedUserDestination: View {
    @StateObject private var viewModel = AppMainThreadInjector.shared.resolve(BlockedUsersViewModel.self)
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    
    var body: some View {
        BlockedUsersView(
            blockedUsers: viewModel.uiState.blockedUsers,
            loading: viewModel.uiState.loading,
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
    let blockedUsers: [User]?
    let loading: Bool
    let onUnblockClick: (String) -> Void
    
    @State private var showUnblockAlert: Bool = false
    @State private var alertUser: User?

    var body: some View {
        List {
            if let blockedUsers {
                if blockedUsers.isEmpty {
                    Text(stringResource(.noBlockedUser))
                        .foregroundStyle(.informationText)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ForEach(blockedUsers) { user in
                        UserItem(
                            user: user,
                            trailingContent: {
                                Button(stringResource(.unblock)) {
                                    alertUser = user
                                    showUnblockAlert = true
                                }
                                .foregroundStyle(.gedPrimary)
                                .fontWeight(.medium)
                            }
                        )
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
            } else {
                ProgressView()
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .listStyle(.plain)
        .loading(loading)
        .navigationTitle(stringResource(.blockedUsers))
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            stringResource(.unblockUserAlertMessage),
            isPresented: $showUnblockAlert,
            presenting: alertUser,
            actions: { user in
                Button(
                    stringResource(.cancel),
                    role: .cancel,
                    action: { showUnblockAlert = false }
                )
                
                Button(stringResource(.unblock)) {
                    onUnblockClick(user.id)
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
            onUnblockClick: { _ in }
        )
        .background(.profileSectionBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
