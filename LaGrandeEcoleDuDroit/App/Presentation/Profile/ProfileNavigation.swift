import SwiftUI

struct ProfileNavigation: View {
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @State private var path: [ProfileRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            ProfileDestination(
                onAccountInfosClick: { path.append(.accountInfos) }
            )
            .onAppear {
                tabBarVisibility.show = true
            }
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                    case .accountInfos:
                        AccountDestination()
                            .onAppear { tabBarVisibility.show = false }
                            .background(Color.background)
                }
            }
        }
    }
}

private enum ProfileRoute {
    case accountInfos
}
