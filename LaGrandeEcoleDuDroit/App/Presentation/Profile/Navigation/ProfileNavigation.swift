import SwiftUI

struct ProfileNavigation: View {
    private let viewModel = AppMainThreadInjector.shared.resolve(ProfileNavigationViewModel.self)
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @State var path: [ProfileRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            ProfileDestination(
                onAccountInfosClick: { path.append(.accountInfos) },
                onAccountClick: { path.append(.account) },
                onPrivacyClick: { path.append(.privacy) }
            )
            .onAppear {
                tabBarVisibility.show = true
                viewModel.setCurrentRoute(ProfileMainRoute.profile)
            }
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                    case .accountInfos:
                        AccountInformationDestination()
                            .onAppear {
                                tabBarVisibility.show = false
                                viewModel.setCurrentRoute(route)
                            }
                            .background(.listBackground)
                        
                    case .account:
                        AccountDestination(
                            onDeleteAccountClick: { path.append(.deleteAccount) }
                        )
                        .onAppear {
                            tabBarVisibility.show = false
                            viewModel.setCurrentRoute(route)
                        }
                        .background(.listBackground)
                        
                    case .deleteAccount:
                        DeleteAccountDestination()
                            .onAppear {
                                tabBarVisibility.show = false
                                viewModel.setCurrentRoute(route)
                            }
                            .background(.listBackground)
                        
                    case .privacy:
                        PrivacyDestination(
                            onBlockedUsersClick: { path.append(.blockedUsers) }
                        )
                        .onAppear {
                            tabBarVisibility.show = false
                            viewModel.setCurrentRoute(route)
                        }
                        .background(.listBackground)
                        
                    case .blockedUsers:
                        BlockedUserDestination(
                            onAccountClick: { path.append(.user($0)) }
                        )
                        .onAppear {
                            tabBarVisibility.show = false
                            viewModel.setCurrentRoute(route)
                        }
                        .background(.listBackground)
                        
                    case let .user(user):
                        UserDestination(user: user)
                            .onAppear {
                                tabBarVisibility.show = false
                                viewModel.setCurrentRoute(route)
                            }
                            .background(.listBackground)
                }
            }
        }
    }
}

enum ProfileRoute: Route {
    case accountInfos
    case account
    case deleteAccount
    case privacy
    case blockedUsers
    case user(User)
}

enum ProfileMainRoute: MainRoute {
    case profile
}
