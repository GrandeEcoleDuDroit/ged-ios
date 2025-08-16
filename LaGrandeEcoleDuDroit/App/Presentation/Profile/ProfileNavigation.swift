import SwiftUI

struct ProfileNavigation: View {
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @State private var path: [ProfileRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            ProfileDestination(
                onAccountInfosClick: { path.append(.accountInfos) }
            )
            .navigationModifier(route: ProfileMainRoute.profile, showTabBar: true)
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                    case .accountInfos:
                        AccountDestination()
                            .navigationModifier(route: route, showTabBar: false)
                            .background(.listBackground)
                }
            }
        }
    }
}

private enum ProfileRoute: Route {
    case accountInfos
}

private enum ProfileMainRoute: Route {
    case profile
}
