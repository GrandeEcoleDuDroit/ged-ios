import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var isInputsFocused: Bool = false
    @State private var isLoading: Bool = false
    @State private var showEmailNotVerifiedAlert: Bool = false
    
    var body: some View {
        NavigationStack(path: $navigationCoordinator.path) {
            VStack(spacing: GedSpacing.veryLarge) {
                Header()
                
                CredentialsInputs(
                    isInputsFocused: $isInputsFocused,
                    email: $authenticationViewModel.email,
                    password: $authenticationViewModel.password,
                    isLoading: isLoading,
                    authenticationState: authenticationViewModel.authenticationState
                )
                .environmentObject(navigationCoordinator)
                
                Buttons(
                    onLoadingButtonClick: {
                        Task {
                            if authenticationViewModel.validateInputs() {
                                await authenticationViewModel.login()
                            }
                        }
                    },
                    isLoading: isLoading
                )
                .environmentObject(authenticationViewModel)
                .environmentObject(navigationCoordinator)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onReceive(authenticationViewModel.$authenticationState) { state in
                showEmailNotVerifiedAlert = state == .emailNotVerified
                isLoading = state == .loading
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isInputsFocused = false
            }
            .alert(
                getString(.emailNotVerified),
                isPresented: $showEmailNotVerifiedAlert,
                presenting: ""
            ) { _ in
                Button(getString(.verifyEmail)) {
                    navigationCoordinator.push(AuthenticationScreen.emailVerification(email: authenticationViewModel.email))
                }
                
                Button(getString(.cancel), role: .cancel) {}
            } message: { _ in
                Text(getString(.emailNotVerifiedDialogMessage))
            }
        }
    }
}

private struct Header: View {
    private let imageWidth = UIScreen.main.bounds.width * 0.4
    private let imageHeight = UIScreen.main.bounds.height * 0.2
    
    var body: some View {
        VStack(spacing: GedSpacing.small) {
            Image(.gedLogo)
                .resizable()
                .scaledToFit()
                .frame(width: imageWidth, height: imageHeight)
            
            Text(getString(.appName))
                .font(.title)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(getString(.authenticationPageSubtitle))
                .font(.body)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(.gedPrimary)
        }
    }
}

private struct CredentialsInputs: View {
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @Binding private var email: String
    @Binding private var password: String
    @Binding var isInputsFocused: Bool
    @State private var inputFieldFocused: InputField?
    @State private var forgottenPasswordClicked: Bool = false
    private var isLoading: Bool
    private var authenticationState: AuthenticationState
    
    init(
        isInputsFocused: Binding<Bool>,
        email: Binding<String>,
        password: Binding<String>,
        isLoading: Bool,
        authenticationState: AuthenticationState
    ) {
        self._isInputsFocused = isInputsFocused
        self._email = email
        self._password = password
        self.isLoading = isLoading
        self.authenticationState = authenticationState
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            FocusableOutlinedTextField(
                title: getString(.email),
                text: $email,
                inputField: InputField.email,
                inputFieldFocused: $inputFieldFocused,
                isDisable: isLoading
            )
            .textInputAutocapitalization(.never)
            .simultaneousGesture(TapGesture().onEnded({
                isInputsFocused = true
            }))
            
            FocusableOutlinedPasswordTextField(
                title: getString(.password),
                text: $password,
                inputField: InputField.password,
                inputFieldFocused: $inputFieldFocused,
                isDisable: isLoading
            )
            .simultaneousGesture(TapGesture().onEnded({
                isInputsFocused = true
            }))
            
            Button(getString(.forgottenPassword)) { navigationCoordinator.push(AuthenticationScreen.forgottenPassword)
            }
            .disabled(isLoading)
            
            if case .error(let message) = authenticationState {
                Text(message)
                    .foregroundColor(.red)
            }
        }
        .onChange(of: isInputsFocused) { isFocused in
            if !isFocused {
                inputFieldFocused = nil
            }
        }
    }
}

private struct Buttons: View {
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var isActive: Bool = false
    private var onLoadingButtonClick: () -> Void
    private var isLoading: Bool
    
    init(
        onLoadingButtonClick: @escaping () -> Void,
        isLoading: Bool
    ) {
        self.onLoadingButtonClick = onLoadingButtonClick
        self.isLoading = isLoading
    }
    
    var body: some View {
        VStack(spacing: GedSpacing.medium) {
            LoadingButton(
                label: getString(.login),
                onClick: onLoadingButtonClick,
                isLoading: isLoading
            )
            
            HStack {
                Text(getString(.notRegisterYet))
                    .foregroundStyle(Color.primary)
                
                Button(getString(.register)) {
                    navigationCoordinator.push(AuthenticationScreen.firstRegistration)
                }
                .foregroundColor(.gedPrimary)
                .fontWeight(.semibold)
                .underline()
            }
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(DependencyContainer.shared.mockAuthenticationViewModel)
        .environmentObject(DependencyContainer.shared.mockRegistrationViewModel)
        .environmentObject(NavigationCoordinator())
}
