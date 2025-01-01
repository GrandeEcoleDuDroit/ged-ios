import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var showLogoutAlert: Bool = false
    
    var body: some View {
        List {
            Section {
                Button(
                    action: { navigationCoordinator.push(ProfileScreen.account) }
                ) {
                    HStack {
                        ProfilePicture(url: profileViewModel.currentUser?.profilePictureUrl, scale: 0.5)
                        
                        if let currentUser = profileViewModel.currentUser {
                            Text(currentUser.fullName)
                                .font(.title3)
                                .fontWeight(.semibold)
                        } else {
                            Text("Unknown")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            
            Section {
                Button(
                    action: { showLogoutAlert = true }
                ) {
                    ItemWithIcon(
                        icon: Image(systemName: "rectangle.portrait.and.arrow.right"),
                        text: Text(getString(.logout))
                    )
                    .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(getString(.profile))
        .alert(
            getString(.logoutAlertMessage),
            isPresented: $showLogoutAlert
        ) {
            Button(getString(.cancel), role: .cancel) {
                showLogoutAlert = false
            }
            
            Button(getString(.logout), role: .destructive) {
                profileViewModel.logout()
            }
        }
    }
}

#Preview {
    struct ProfileView_Previews: View {
        @StateObject private var navigationCoordinator = NavigationCoordinator()
        
        var body: some View {
            NavigationStack(path: $navigationCoordinator.path) {
                ProfileView()
                    .environmentObject(DependencyContainer.shared.mockProfileViewModel)
                    .environmentObject(navigationCoordinator)
                    .navigationDestination(for: ProfileScreen.self) { screen in
                        if case .account = screen {
                            AccountView()
                                .environmentObject(DependencyContainer.shared.mockProfileViewModel)
                        }
                    }
            }
        }
    }
    
    return ProfileView_Previews()
}
