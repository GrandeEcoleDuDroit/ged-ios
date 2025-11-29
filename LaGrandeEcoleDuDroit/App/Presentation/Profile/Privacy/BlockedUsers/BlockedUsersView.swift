import SwiftUI

struct BlockedUserDestination: View {
    private let onAccountClick: (User) -> Void
    
    @StateObject private var viewModel = AppMainThreadInjector.shared.resolve(BlockedUsersViewModel.self)
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    
    init(onAccountClick: @escaping (User) -> Void) {
        self.onAccountClick = onAccountClick
    }
    
    
    var body: some View {
        BlockedUsersView(
            onAccountClick: onAccountClick,
            onUnblockClick: viewModel.unblockUser,
            blockedUsers: viewModel.uiState.blockedUsers,
            loading: viewModel.uiState.loading
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
    let onAccountClick: (User) -> Void
    let onUnblockClick: (String) -> Void
    let blockedUsers: [User]
    let loading: Bool
    
    @State private var showUnblockAlert: Bool = false
    @State private var clickedUser: User?

    var body: some View {
        List {
            if blockedUsers.isEmpty {
                Text(stringResource(.noBlockedUser))
                    .foregroundStyle(.informationText)
                    .frame(maxWidth: .infinity, alignment: .top)
            } else {
                ForEach(blockedUsers) { user in
                    Button(action: { onAccountClick(user) }) {
                        UserItem(
                            user: user,
                            trailingContent: {
                                Button(
                                    action: {
                                        showUnblockAlert = true
                                        clickedUser = user
                                    },
                                    label: {
                                        Text(stringResource(.unblock))
                                            .foregroundStyle(.gedPrimary)
                                            .fontWeight(.medium)
                                    }
                                )
                                .buttonStyle(.plain)
                            }
                        )
                    }
                    .buttonStyle(ClickStyle())
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.background)
                }
            }
        }
        .listStyle(.plain)
        .listRowSeparator(.hidden)
        .scrollIndicators(.hidden)
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
            onAccountClick: { _ in },
            onUnblockClick: { _ in },
            blockedUsers: usersFixture,
            loading: false
        )
    }.background(Color.background)
}
