import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @State private var showLogoutAlert: Bool = false
    
    var body: some View {
        VStack {
            List {
                Section {
                    NavigationLink(destination: destinationView(for: MenuItemData.Name.account)) {
                        HStack {
                            if let profilePictureUrl = profileViewModel.currentUser?.profilePictureUrl {
                                ProfilePicture(url: profilePictureUrl, scale: 0.2)
                            } else {
                                DefaultProfilePicture(scale: 0.5)
                            }
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
                        MenuItem(
                            icon: Image(systemName: "rectangle.portrait.and.arrow.right"),
                            title: getString(gedString: GedString.logout),
                            color: .red
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.clear)
                        .contentShape(Rectangle())
                    }
                }
            }
        }
        .navigationTitle(getString(gedString: GedString.profile))
        .alert(
            getString(gedString: GedString.logout_alert_message),
            isPresented: $showLogoutAlert
        ) {
            Button(getString(gedString: GedString.cancel), role: .cancel) {
                showLogoutAlert = false
            }
            
            Button(getString(gedString: GedString.logout), role: .destructive) {
                profileViewModel.logout()
            }
        }
    }
    
    func destinationView(for menuName: MenuItemData.Name) -> some View {
        switch menuName {
        case .account:
            AnyView(AccountView())
        }
    }
}

#Preview {
    NavigationView {
        ProfileView()
            .environmentObject(DependencyContainer.shared.profileViewModel)
    }
}
