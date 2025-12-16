import SwiftUI

struct ProfileNavigation: View {
    @StateObject private var viewModel = AppMainThreadInjector.shared.resolve(ProfileNavigationViewModel.self)

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ProfileDestination(
                onAccountInfosClick: { viewModel.path.append(.accountInfos) },
                onAccountClick: { viewModel.path.append(.account) },
                onPrivacyClick: { viewModel.path.append(.privacy) }
            )
            .toolbar(viewModel.path.isEmpty ? .visible : .hidden, for: .tabBar)
            .background(.profileSectionBackground)
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                    case .accountInfos:
                        AccountInformationDestination()
                            .background(.profileSectionBackground)
                        
                    case .account:
                        AccountDestination(
                            onDeleteAccountClick: { viewModel.path.append(.deleteAccount) }
                        )
                        .background(.profileSectionBackground)
                        
                    case .deleteAccount:
                        DeleteAccountDestination()
                            .background(.profileSectionBackground)
                        
                    case .privacy:
                        PrivacyDestination(
                            onBlockedUsersClick: { viewModel.path.append(.blockedUsers) }
                        )
                        .background(.profileSectionBackground)
                        
                    case .blockedUsers:
                        BlockedUserDestination(
                            onAccountClick: { viewModel.path.append(.user($0)) }
                        )
                        .background(.profileSectionBackground)
                        
                    case let .user(user):
                        UserDestination(user: user)
                            .background(.profileSectionBackground)
                }
            }
        }
    }
}
