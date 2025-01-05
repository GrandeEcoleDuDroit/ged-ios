import SwiftUI

struct ProfileNavigation: View {
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @StateObject private var profileNavigationCoordinator = CommonDependencyInjectionContainer.shared.resolve(NavigationCoordinator.self)
    @StateObject private var profileViewModel = ProfileDependencyInjectionContainer.shared.resolve(ProfileViewModel.self)

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
    struct ProfileNavigation_Preview: View {
        @StateObject var navigationCoordinator = CommonDependencyInjectionContainer.shared.resolve(NavigationCoordinator.self)
        let tabBarVisibility = CommonDependencyInjectionContainer.shared.resolve(TabBarVisibility.self)
        let mockProfileViewModel = ProfileDependencyInjectionContainer.shared.resolveWithMock().resolve(ProfileViewModel.self)!
        
        var body: some View {
            NavigationStack(path: $navigationCoordinator.path) {
                ProfileView()
                    .navigationDestination(for: ProfileScreen.self) { screen in
                        switch screen {
                        case .account:
                            AccountView()
                        }
                    }
            }
            .environmentObject(navigationCoordinator)
            .environmentObject(tabBarVisibility)
            .environmentObject(mockProfileViewModel)
        }
    }
    
    return ProfileNavigation_Preview()
}
