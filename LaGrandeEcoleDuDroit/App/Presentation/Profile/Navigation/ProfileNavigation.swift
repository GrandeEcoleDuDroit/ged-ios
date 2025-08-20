import SwiftUI

struct ProfileNavigation: View {
    private let viewModel = MainInjection.shared.resolve(ProfileNavigationViewModel.self)
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @State var path: [ProfileRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            ProfileDestination(
                onAccountInfosClick: { path.append(.accountInfos) }
            )
            .onAppear {
                tabBarVisibility.show = true
                viewModel.setCurrentRoute(ProfileMainRoute.profile)
            }
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                    case .accountInfos:
                        AccountDestination()
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
}

enum ProfileMainRoute: MainRoute {
    case profile
}
