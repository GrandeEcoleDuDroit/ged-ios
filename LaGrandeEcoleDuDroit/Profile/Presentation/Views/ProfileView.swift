import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @State private var showLogoutAlert: Bool = false
    
    var body: some View {
        List {
            Section {
                NavigationLink(value: ProfileScreen.account) {
                    HStack {
                        ProfilePicture(url: profileViewModel.currentUser?.profilePictureUrl, scale: 0.5)
                        
                        if let currentUser = profileViewModel.currentUser {
                            Text(currentUser.fullName)
                                .font(.titleMedium)
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
        .navigationDestination(for: ProfileScreen.self) { screen in
            switch screen {
            case .account:
                AccountView()
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
    NavigationStack {
        ProfileView()
            .environmentObject(DependencyContainer.shared.mockProfileViewModel)
    }
}
