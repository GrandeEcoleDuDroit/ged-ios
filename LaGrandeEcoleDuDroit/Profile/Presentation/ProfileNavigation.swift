import SwiftUI

struct ProfileNavigation: View {
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @StateObject private var profileNavigationCoordinator = NavigationCoordinator()
    
    var body: some View {
        NavigationStack(path: $profileNavigationCoordinator.path) {
            ProfileView()
                .navigationDestination(for: ProfileScreen.self) { screen in
                    switch screen {
                        case .accountInfos:
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
        @StateObject var navigationCoordinator = NavigationCoordinator()
        let tabBarVisibility = TabBarVisibility()
        let mockProfileViewModel = ProfileInjection.shared.resolveWithMock().resolve(ProfileViewModel.self)!
        
        var body: some View {
            NavigationStack(path: $navigationCoordinator.path) {
                ProfileView()
                    .navigationDestination(for: ProfileScreen.self) { screen in
                        switch screen {
                            case .accountInfos:
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
