import SwiftUI

struct AuthenticationView: View {
    @StateObject private var authenticationViewModel = AuthenticationViewModel()
    @State private var isInputsFocused: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: GedSpacing.verylLarge) {
                Header()
                
                CredentialsInputs(isInputsFocused: $isInputsFocused)
                    .environmentObject(authenticationViewModel)
                
                Buttons()
                    .environmentObject(authenticationViewModel)
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
    private let titleAuthenticationPage = NSLocalizedString(GedString.appName, comment: "")
    private let subtitleAuthenticationPage = NSLocalizedString(GedString.authenticationPageSubtitle, comment: "")
    
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
    
    @State private var inputFocused: InputField?
    private let titleEmailTextField = NSLocalizedString(GedString.email, comment: "")
    private let titlePasswordTextField = NSLocalizedString(GedString.password, comment: "")
    private let forgottenPassword = NSLocalizedString(GedString.forgotten_password, comment: "")
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            
            FocusableOutlinedTextField(
                title: titleEmailTextField,
                text: $authenticationViewModel.email,
                defaultFocusValue: InputField.email,
                inputFocused: $inputFocused,
                isDisable: $authenticationViewModel.isLoading
            )
            .simultaneousGesture(TapGesture().onEnded({
                isInputsFocused = true
            }))
            
            FocusableOutlinedPasswordTextField(
                title: titlePasswordTextField,
                text: $authenticationViewModel.password,
                defaultFocusValue: InputField.password,
                inputFocused: $inputFocused,
                isDisable: $authenticationViewModel.isLoading
            )
            .simultaneousGesture(TapGesture().onEnded({
                isInputsFocused = true
            }))
            
            NavigationLink(destination: {}) {
                Text(forgottenPassword)
                    .foregroundColor(.primary)
            }
            
            .disabled(authenticationViewModel.isLoading)
            
            if authenticationViewModel.errorMessage != nil {
                Text(authenticationViewModel.errorMessage!)
                    .foregroundColor(.red)
            }
        }
        .onChange(of: isInputsFocused) { newValue in
            if !newValue {
                inputFocused = nil
            }
        }
    }
}

private struct Buttons: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    
    private let login = NSLocalizedString(GedString.login, comment: "")
    private let register = NSLocalizedString(GedString.register, comment: "")
    private let notRegisterYet = NSLocalizedString(GedString.not_register_yet, comment: "")
    
    var body: some View {
        VStack(spacing: GedSpacing.medium) {
            NavigationLink(destination: {}) {
                LoadingButton(
                    label: login,
                    onClick: {
                        if authenticationViewModel.validateInputs() {
                            authenticationViewModel.login()
                        }
                    },
                    isLoading: $authenticationViewModel.isLoading
                )
            }
            
            HStack {
                Text(notRegisterYet)
                NavigationLink(destination: FirstRegistrationView()) {
                    Text(register)
                        .foregroundColor(Color(GedColor.primary))
                        .fontWeight(.semibold)
                        .underline()
                }
                .disabled(authenticationViewModel.isLoading)
            }
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationViewModel())
}
