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
        List {
            if let user {
                Section {
                    Button(action: onAccountInfosClick) {
                        HStack(spacing: Dimens.mediumPadding) {
                            ProfilePicture(url: user.profilePictureUrl, scale: 0.5)
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(user.fullName)
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
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                        }
                    }
                }
                
                Section {
                    Button(action: onAccountClick) {
                        ListItem(
                            image: Image(systemName: "key"),
                            text: Text(stringResource(.account))
                        )
                    }
                    
                    Button(action: onPrivacyClick) {
                        ListItem(
                            image: Image(systemName: "lock"),
                            text: Text(stringResource(.privacy))
                        )
                    }
                }
                
                Section {
                    ClickableTextItem(
                        icon: Image(systemName: "rectangle.portrait.and.arrow.right"),
                        text: Text(stringResource(.logout)),
                        onClick: { showLogoutAlert = true }
                    )
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
