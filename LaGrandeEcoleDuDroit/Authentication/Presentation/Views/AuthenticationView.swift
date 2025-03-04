import SwiftUI

struct AuthenticationView: View {
    @StateObject private var authenticationViewModel: AuthenticationViewModel = AuthenticationInjection.shared.resolve(AuthenticationViewModel.self)
    @State private var isInputsFocused: Bool = false
    @State private var isLoading: Bool = false
    @State private var showEmailNotVerifiedAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: GedSpacing.veryLarge) {
                Header()
                
                CredentialsInputs(
                    isInputsFocused: $isInputsFocused,
                    email: $authenticationViewModel.email,
                    password: $authenticationViewModel.password,
                    isLoading: isLoading,
                    screenState: authenticationViewModel.screenState
                )
                
                Buttons(
                    onLoadingButtonClick: {
                        if authenticationViewModel.validateInputs() {
                            authenticationViewModel.login()
                        }
                    },
                    isLoading: isLoading
                )
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onReceive(authenticationViewModel.$screenState) { state in
                showEmailNotVerifiedAlert = state == .emailNotVerified
                isLoading = state == .loading
            }
            .contentShape(Rectangle())
            .onTapGesture { isInputsFocused = false }
            .alert(
                getString(.emailNotVerified),
                isPresented: $showEmailNotVerifiedAlert
            ) {
                NavigationLink(
                    getString(.verifyEmail),
                    destination: EmailVerificationView(email: authenticationViewModel.email)
                )
                
                Button(getString(.cancel), role: .cancel) {
                    showEmailNotVerifiedAlert = false
                }
            } message: {
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
        }
    }
}

private struct CredentialsInputs: View {
    @Binding private var email: String
    @Binding private var password: String
    @Binding var isInputsFocused: Bool
    @State private var inputFieldFocused: InputField?
    @State private var forgotPasswordClicked: Bool = false
    private var isLoading: Bool
    private var screenState: AuthenticationScreenState
    
    init(
        isInputsFocused: Binding<Bool>,
        email: Binding<String>,
        password: Binding<String>,
        isLoading: Bool,
        screenState: AuthenticationScreenState
    ) {
        self._isInputsFocused = isInputsFocused
        self._email = email
        self._password = password
        self.isLoading = isLoading
        self.screenState = screenState
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            FillTextField(
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
            
            FillPasswordTextField(
                title: getString(.password),
                text: $password,
                inputField: InputField.password,
                inputFieldFocused: $inputFieldFocused,
                isDisable: isLoading
            )
            .simultaneousGesture(TapGesture().onEnded({
                isInputsFocused = true
            }))
            
            Button(getString(.forgotPassword)) {
                forgotPasswordClicked = true
            }
            .disabled(isLoading)
            
            if case .error(let message) = screenState {
                Text(message)
                    .foregroundColor(.red)
            }
        }
        .onChange(of: isInputsFocused) { isFocused in
            if !isFocused {
                inputFieldFocused = nil
            }
        }
        .navigationDestination(isPresented: $forgotPasswordClicked) {
            ForgotPasswordView()
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
                
                NavigationLink(getString(.register), destination: FirstRegistrationView())
                    .foregroundColor(.gedPrimary)
                    .fontWeight(.semibold)
                    .underline()
            }
        }
    }
}

#Preview {
    NavigationStack {
        AuthenticationView()
            .environmentObject(NavigationCoordinator())
    }
}
