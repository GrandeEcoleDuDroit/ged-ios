import SwiftUI

struct ProfileDestination: View {
    let onAccountInfosClick: () -> Void
    
    @StateObject private var viewModel = ProfileInjection.shared.resolve(ProfileViewModel.self)
    
    var body: some View {
        ProfileView(
            user: viewModel.uiState.user,
            onAccountInfosClick: onAccountInfosClick,
            onLogoutClick: viewModel.logout
        )
        .background(.listBackground)
    }
}

private struct ProfileView: View {
    let user: User?
    let onAccountInfosClick: () -> Void
    let onLogoutClick: () -> Void
    @State private var showLogoutAlert: Bool = false

    var body: some View {
        ZStack {
            if let user = user {
                List {
                    Section {
                        Button(
                            action: onAccountInfosClick
                        ) {
                            HStack {
                                ProfilePicture(url: user.profilePictureFileName, scale: 0.5)
                                
                                Text(user.fullName)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .listRowBackground(Color.listRowBackground)
                    
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
                    .listRowBackground(Color.listRowBackground)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
            
            Button(
                getString(.logout), role: .destructive,
                action: onLogoutClick
            )
        }
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    NavigationStack {
        ProfileView(
            user: userFixture,
            onAccountInfosClick: {},
            onLogoutClick: {}
        )
        .background(.listBackground)
    }
}
