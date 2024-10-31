import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @State private var isInputsFocused: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: GedSpacing.verylLarge) {
                Header()
                
                CredentialsInputs(isInputsFocused: $isInputsFocused)
                    .environmentObject(authenticationViewModel)
                
                Buttons()
                    .environmentObject(authenticationViewModel)
                    .environmentObject(registrationViewModel)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(UIColor.systemBackground))
            .onTapGesture {
                isInputsFocused = false
            }
        }
    }
}

private struct Header: View {
    private let imageWidth = UIScreen.main.bounds.width * 0.4
    private let imageHeight = UIScreen.main.bounds.height * 0.2
    private let titleAuthenticationPage = getString(gedString: GedString.appName)
    private let subtitleAuthenticationPage = getString(gedString: GedString.authenticationPageSubtitle)
    
    var body: some View {
        VStack(spacing: GedSpacing.small) {
            Image(.gedLogo)
                .resizable()
                .scaledToFit()
                .frame(width: imageWidth, height: imageHeight)
            
            Text(titleAuthenticationPage)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(subtitleAuthenticationPage)
                .font(.body)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(Color(GedColor.primary))
        }
    }
}

private struct CredentialsInputs: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @Binding var isInputsFocused: Bool
    @State private var isLoading: Bool = false
    @State private var inputFocused: InputField?
    private let titleEmailTextField = getString(gedString: GedString.email)
    private let titlePasswordTextField = getString(gedString: GedString.password)
    private let forgottenPassword = getString(gedString: GedString.forgotten_password)
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            FocusableOutlinedTextField(
                title: titleEmailTextField,
                text: $authenticationViewModel.email,
                defaultFocusValue: InputField.email,
                inputFocused: $inputFocused,
                isDisable: $isLoading
            )
            .simultaneousGesture(TapGesture().onEnded({
                isInputsFocused = true
            }))
            
            FocusableOutlinedPasswordTextField(
                title: titlePasswordTextField,
                text: $authenticationViewModel.password,
                defaultFocusValue: InputField.password,
                inputFocused: $inputFocused,
                isDisable: $isLoading
            )
            .simultaneousGesture(TapGesture().onEnded({
                isInputsFocused = true
            }))
            
            NavigationLink(destination: {}) {
                Text(forgottenPassword)
                    .foregroundColor(.primary)
            }.disabled(isLoading)
            
            if case .error(let message) = authenticationViewModel.authenticationState {
                Text(message)
                    .foregroundColor(.red)
            }
        }
        .onChange(of: isInputsFocused) { isFocused in
            if !isFocused {
                inputFocused = nil
            }
        }
        .onReceive(authenticationViewModel.$authenticationState) { state in
            isLoading = state == .loading
        }
    }
    
    
}

private struct Buttons: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    
    private let login = getString(gedString: GedString.login)
    private let register = getString(gedString: GedString.register)
    private let notRegisterYet = getString(gedString: GedString.not_register_yet)
    @State private var isLoading: Bool = false
    @State private var destination = AnyView(FirstRegistrationView())
    @State private var showDialog: Bool = false
    @State private var isActive: Bool = false
    
    var body: some View {
        NavigationLink(
            destination: destination,
            isActive: $isActive
        ) {
            VStack(spacing: GedSpacing.medium) {
                LoadingButton(
                    label: login,
                    onClick: {
                        if authenticationViewModel.validateInputs() {
                            authenticationViewModel.login()
                        }
                    },
                    isLoading: $isLoading
                )
                
                HStack {
                    Text(notRegisterYet)
                        .foregroundStyle(Color.primary)
                    Text(register)
                        .foregroundColor(Color(GedColor.primary))
                        .fontWeight(.semibold)
                        .underline()
                        .onTapGesture {
                            destination = AnyView(
                                FirstRegistrationView()
                                    .environmentObject(registrationViewModel)
                            )
                            isActive = true
                        }
                }.disabled(isLoading)
            }
            .onReceive(authenticationViewModel.$authenticationState) { state in
                switch state {
                case .emailNotVerified:
                    showDialog = true
                default:
                    destination = AnyView(NewsView())
                }
                isLoading = state == .loading
            }
            .alert(
                getString(gedString: GedString.email_not_verified),
                isPresented: $showDialog,
                presenting: ""
            ) { data in
                Button(getString(gedString: GedString.verify_email)) {
                    destination = AnyView(
                        EmailVerificationView()
                            .environmentObject(RegistrationViewModel(email: authenticationViewModel.email))
                    )
                    isActive = true
                }
                Button(getString(gedString: GedString.cancel), role: .cancel) {}
            } message: { data in
                Text(getString(gedString: GedString.email_not_verified_dialog_message))
            }
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(RegistrationViewModel())
}
