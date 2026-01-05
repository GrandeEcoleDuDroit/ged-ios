import SwiftUI

struct ProfileDestination: View {
    let onAccountInfosClick: () -> Void
    let onAccountClick: () -> Void
    let onPrivacyClick: () -> Void
    
    @StateObject private var viewModel = AppMainThreadInjector.shared.resolve(ProfileViewModel.self)
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    
    var body: some View {
        ProfileView(
            user: viewModel.uiState.user,
            onAccountInfosClick: onAccountInfosClick,
            onAccountClick: onAccountClick,
            onPrivacyClick: onPrivacyClick,
            onLogoutClick: viewModel.logout
        )
        .onReceive(viewModel.$event) { event in
            if let errorEvent = event as? ErrorEvent {
                errorMessage = errorEvent.message
                showErrorAlert = true
            }
        }
        .alert(
            errorMessage,
            isPresented: $showErrorAlert,
            actions: {
                Button(stringResource(.ok)) {
                    showErrorAlert = false
                }
            }
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
        List {
            if let user {
                Section {
                    NavigationListItem(onClick: onAccountInfosClick) {
                        HStack(spacing: Dimens.mediumPadding) {
                            ProfilePicture(url: user.profilePictureUrl, scale: 0.5)
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(user.displayedName)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                    
                                    if user.admin {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(.gold)
                                            .font(.system(size: 14))
                                    }
                                }
                                
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                
                Section {
                    NavigationListItem(
                        image: Image(systemName: "key"),
                        text: stringResource(.account),
                        onClick: onAccountClick
                    )

                    NavigationListItem(
                        image: Image(systemName: "lock"),
                        text: stringResource(.privacy),
                        onClick: onPrivacyClick
                    )
                }
                
                Section {
                    Button(action: { showLogoutAlert = true }) {
                        TextIcon(
                            icon: Image(systemName: "rectangle.portrait.and.arrow.right"),
                            text: stringResource(.logout)
                        )
                    }
                    .foregroundStyle(.red)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            }
        }
        .navigationTitle(stringResource(.profile))
        .scrollContentBackground(.hidden)
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
        .background(.profileSectionBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
