import SwiftUI

struct ProfileDestination: View {
    let onAccountInfosClick: () -> Void
    let onAccountClick: () -> Void
    let onPrivacyClick: () -> Void
    
    @StateObject private var viewModel = AppMainThreadInjector.shared.resolve(ProfileViewModel.self)
    
    var body: some View {
        ProfileView(
            user: viewModel.uiState.user,
            onAccountInfosClick: onAccountInfosClick,
            onAccountClick: onAccountClick,
            onPrivacyClick: onPrivacyClick,
            onLogoutClick: viewModel.logout
        )
    }
}

private struct ProfileView: View {
    let user: User?
    let onAccountInfosClick: () -> Void
    let onAccountClick: () -> Void
    let onPrivacyClick: () -> Void
    let onLogoutClick: () -> Void
    
    @State private var showLogoutAlert: Bool = false

    var body: some View {
        ZStack {
            if let user {
                List {
                    Section {
                        Button(
                            action: onAccountInfosClick
                        ) {
                            HStack(
                                alignment: .center,
                                spacing: Dimens.mediumPadding
                            ) {
                                ProfilePicture(url: user.profilePictureUrl, scale: 0.5)
                                
                                VStack(alignment: .leading) {
                                    Text(user.fullName)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    
                                    Text(user.email)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                    
                    Section {
                        MenuItem(
                            icon: Image(systemName: "key"),
                            title: stringResource(.account),
                            onClick: onAccountClick
                        )
                        
                        MenuItem(
                            icon: Image(systemName: "lock"),
                            title: stringResource(.privacy),
                            onClick: onPrivacyClick
                        )
                    }
                    
                    Section {
                        ClickableTextItem(
                            icon: Image(systemName: "rectangle.portrait.and.arrow.right"),
                            text: Text(stringResource(.logout)),
                            onClick: { showLogoutAlert = true }
                        )
                        .foregroundStyle(.red)
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .navigationTitle(stringResource(.profile))
        .alert(
            stringResource(.logoutAlertMessage),
            isPresented: $showLogoutAlert,
            actions: {
                Button(stringResource(.cancel), role: .cancel) {
                    showLogoutAlert = false
                }
                
                Button(
                    stringResource(.logout), role: .destructive,
                    action: onLogoutClick
                )
            }
        )
        .scrollContentBackground(.hidden)
        .background(.listBackground)
    }
}

#Preview {
    NavigationStack {
        ProfileView(
            user: userFixture,
            onAccountInfosClick: {},
            onAccountClick: {},
            onPrivacyClick: {},
            onLogoutClick: {}
        )
        .background(.listBackground)
    }
}
