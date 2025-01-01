import SwiftUI

struct ProfileNavigation: View {
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @StateObject private var profileNavigationCoordinator = NavigationCoordinator()
    @StateObject private var profileViewModel = DependencyContainer.shared.profileViewModel

    var body: some View {
        NavigationStack(path: $profileNavigationCoordinator.path) {
            ProfileView()
                .environmentObject(profileViewModel)
                .navigationDestination(for: ProfileScreen.self) { screen in
                    switch screen {
                    case .account:
                        AccountView()
                    }
                }
        }
        .environmentObject(profileNavigationCoordinator)
        .environmentObject(tabBarVisibility)
    }
}

#Preview {
    struct ProfileNavigation_Previews: View {
        @StateObject var navigationCoordinator = NavigationCoordinator()
        
        var body: some View {
            NavigationStack(path: $navigationCoordinator.path) {
                ProfileView()
                    .environmentObject(DependencyContainer.shared.mockProfileViewModel)
                    .navigationDestination(for: ProfileScreen.self) { screen in
                        switch screen {
                        case .account:
                            AccountView()
                        }
                    }
            }
            .environmentObject(navigationCoordinator)
            .environmentObject(TabBarVisibility())
        }
    }
    
    return ProfileNavigation_Previews()
}
