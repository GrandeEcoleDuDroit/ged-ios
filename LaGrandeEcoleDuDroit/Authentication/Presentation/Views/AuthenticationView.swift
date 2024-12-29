import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @StateObject private var coordinator = AuthenticationNavigationCoordinator()
    @State private var isInputsFocused: Bool = false
    @State private var isLoading: Bool = false
    @State private var showEmailNotVerifiedAlert: Bool = false
    
    var body: some View {
        NavigationStack(path: $coordinator.paths) {
            VStack(spacing: GedSpacing.verylLarge) {
                Header()
                
                CredentialsInputs(
                    isInputsFocused: $isInputsFocused,
                    email: $authenticationViewModel.email,
                    password: $authenticationViewModel.password,
                    isLoading: isLoading,
                    authenticationState: authenticationViewModel.authenticationState
                )
                
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
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .contentShape(Rectangle())
            .onReceive(authenticationViewModel.$authenticationState) { state in
                showEmailNotVerifiedAlert = state == .emailNotVerified
                isLoading = state == .loading
            }
            .onTapGesture {
                isInputsFocused = false
            }
            .navigationDestination(for: AuthenticationScreen.self) { screen in
                switch screen {
                case .forgottenPassword:
                    Text(getString(.forgottenPassword))
                case .emailVerification:
                    let registrationViewModel = RegistrationViewModel(
                        email: authenticationViewModel.email,
                        registerUseCase: DependencyContainer.shared.registerUseCase,
                        sendVerificationEmailUseCase: DependencyContainer.shared.sendVerificationEmailUseCase,
                        isEmailVerifiedUseCase: DependencyContainer.shared.isEmailVerifiedUseCase,
                        createUserUseCase: DependencyContainer.shared.createUserUseCase
                    )
                    EmailVerificationView().environmentObject(registrationViewModel)
                case .firstRegistration:
                    FirstRegistrationView()
                        .environmentObject(registrationViewModel)
                default: EmptyView()
                }
            }
            .alert(
                getString(.emailNotVerified),
                isPresented: $showEmailNotVerifiedAlert,
                presenting: ""
            ) { _ in
                NavigationLink(value: AuthenticationScreen.emailVerification) {
                    Text(getString(.verifyEmail))
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
    @Binding private var email: String
    @Binding private var password: String
    @Binding var isInputsFocused: Bool
    @State private var inputFocused: InputField?
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
                defaultFocusValue: InputField.email,
                inputFocused: $inputFocused,
                isDisable: isLoading
            )
            .simultaneousGesture(TapGesture().onEnded({
                isInputsFocused = true
            }))
            
            FocusableOutlinedPasswordTextField(
                title: getString(.password),
                text: $password,
                defaultFocusValue: InputField.password,
                inputFocused: $inputFocused,
                isDisable: isLoading
            )
            .simultaneousGesture(TapGesture().onEnded({
                isInputsFocused = true
            }))
            
            NavigationLink(value: AuthenticationScreen.forgottenPassword) {
                Text(getString(.forgottenPassword))
                    .foregroundStyle(.accent)
            }
            .disabled(isLoading)
            
            if case .error(let message) = authenticationState {
                Text(message)
                    .foregroundColor(.red)
            }
        }
        .onChange(of: isInputsFocused) { isFocused in
            if !isFocused {
                inputFocused = nil
            }
        }
    }
}

private struct Buttons: View {
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
                
                NavigationLink(value: AuthenticationScreen.firstRegistration) {
                    Text(getString(.register))
                        .foregroundColor(.gedPrimary)
                        .fontWeight(.semibold)
                        .underline()
                }
            }
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(DependencyContainer.shared.mockAuthenticationViewModel)
        .environmentObject(DependencyContainer.shared.mockRegistrationViewModel)
        .environmentObject(AuthenticationNavigationCoordinator())
}
