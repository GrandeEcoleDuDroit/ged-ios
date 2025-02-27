import SwiftUI

struct ProfileView: View {
    @StateObject private var profileViewModel = ProfileInjection.shared.resolve(ProfileViewModel.self)
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var showLogoutAlert: Bool = false
    
    var body: some View {
        List {
            Section {
                Button(
                    action: { navigationCoordinator.push(ProfileScreen.accountInfos) }
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
            getString(.logoutAlertTitle),
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
    NavigationStack {
        ProfileView()
    }
}
