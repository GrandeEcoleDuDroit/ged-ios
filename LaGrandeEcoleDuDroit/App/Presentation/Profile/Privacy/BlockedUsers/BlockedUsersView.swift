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
                Button(getString(.ok)) {
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
        ScrollView {
            if blockedUsers.isEmpty {
                Text(getString(.noBlockedUser))
                    .foregroundColor(.informationText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .top)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(blockedUsers) { user in
                        Clickable(
                            action: { onAccountClick(user) },
                            content: {
                                UserItem(
                                    user: user,
                                    trailingContent: {
                                        Button(
                                            action: {
                                                showUnblockAlert = true
                                                clickedUser = user
                                            },
                                            label: {
                                                Text(getString(.unblock))
                                                    .foregroundStyle(.gedPrimary)
                                                    .fontWeight(.medium)
                                            }
                                        )
                                    }
                                )
                            }
                        )
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .scrollIndicators(.hidden)
        .loading(loading)
        .navigationTitle(getString(.blockedUsers))
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            getString(.unblockUserAlertMessage),
            isPresented: $showUnblockAlert,
            actions: {
                Button(
                    getString(.cancel),
                    role: .cancel,
                    action: { showUnblockAlert = false }
                )
                
                Button(getString(.unblock)) {
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
