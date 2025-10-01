import SwiftUI

struct ProfileNavigation: View {
    private let viewModel = AppInjector.shared.resolve(ProfileNavigationViewModel.self)
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @State var path: [ProfileRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            ProfileDestination(
                onAccountInfosClick: { path.append(.accountInfos) },
                onAccountClick: { path.append(.account) }
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
                        AccountDestination(onDeleteAccountClick: { path.append(.deleteAccount) })
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
                }
            }
        }
    }
}

enum ProfileRoute: Route {
    case accountInfos
    case account
    case deleteAccount
}

enum ProfileMainRoute: MainRoute {
    case profile
}
