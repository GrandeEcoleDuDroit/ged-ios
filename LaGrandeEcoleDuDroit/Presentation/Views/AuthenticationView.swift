import SwiftUI

struct AuthenticationView: View {
    @StateObject private var authenticationViewModel = AuthenticationViewModel()
    @State private var isInputsFocused: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: GedSpacing.verylLarge) {
                Header()
                
                Inputs(
                    email: $authenticationViewModel.email,
                    password: $authenticationViewModel.password,
                    onForgottenPasswordClick: {},
                    isInputsFocused: $isInputsFocused,
                    errorMessage: $authenticationViewModel.errorMessage,
                    isLoading: $authenticationViewModel.isLoading
                )
                
                Buttons(
                    onLoginClick: {
                        if authenticationViewModel.validateInputs() {
                            authenticationViewModel.login()
                        }
                    },
                    onRegisterClick: {},
                    isLoading: $authenticationViewModel.isLoading
                )
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemBackground))
        .onTapGesture {
            isInputsFocused = false
        }
    }
}

private struct Header: View {
    private let imageWidth = UIScreen.main.bounds.width * 0.4
    private let imageHeight = UIScreen.main.bounds.height * 0.2
    private let titleAuthenticationPage = NSLocalizedString(GedStrings.appName, comment: "")
    private let subtitleAuthenticationPage = NSLocalizedString(GedStrings.authenticationPageSubtitle, comment: "")
    
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

private struct Inputs: View {
    @Binding var email: String
    @Binding var password: String
    let onForgottenPasswordClick: () -> Void
    @Binding var isInputsFocused: Bool
    @Binding var errorMessage: String?
    @Binding var isLoading: Bool
    
    @State private var inputState: InputField?
    private let titleEmailTextField = NSLocalizedString(GedStrings.email, comment: "")
    private let titlePasswordTextField = NSLocalizedString(GedStrings.password, comment: "")
    private let forgottenPassword = NSLocalizedString(GedStrings.forgotten_password, comment: "")
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.smallMedium) {
            
            FocusableOutlinedTextField(
                title: titleEmailTextField,
                text: $email,
                focusValue: InputField.email,
                inputState: $inputState,
                isDisable: $isLoading
            )
            .simultaneousGesture(TapGesture().onEnded({
                inputState = InputField.email
                isInputsFocused = true
            }))
            
            FocusableOutlinedPasswordTextField(
                title: titlePasswordTextField,
                text: $password,
                focusValue: InputField.password,
                inputState: $inputState,
                isDisable: $isLoading
            )
            .simultaneousGesture(TapGesture().onEnded({
                inputState = InputField.password
                isInputsFocused = true
            }))
            
            Button(action: onForgottenPasswordClick) {
                Text(forgottenPassword)
                    .foregroundColor(.primary)
            }
            .disabled(isLoading)
            
            if errorMessage != nil {
                Text(errorMessage!)
                    .foregroundColor(.red)
            }
        }
        .onChange(of: isInputsFocused) { newValue in
            if !newValue {
                inputState = nil
            }
        }
    }
}

private struct Buttons: View {
    let onLoginClick: () -> Void
    let onRegisterClick: () -> Void
    @Binding var isLoading: Bool
    
    private let login = NSLocalizedString(GedStrings.login, comment: "")
    private let register = NSLocalizedString(GedStrings.register, comment: "")
    private let notRegisterYet = NSLocalizedString(GedStrings.not_register_yet, comment: "")
    
    var body: some View {
        VStack(spacing: GedSpacing.medium) {
            LoadingButton(label: login, onClick: onLoginClick, isLoading: $isLoading)
            
            HStack {
                Text(notRegisterYet)
                Button(action: onLoginClick) {
                    Text(register)
                        .foregroundColor(Color(GedColor.primary))
                        .fontWeight(.semibold)
                        .underline()
                        
                }
                .disabled(isLoading)
            }
        }
    }
}

#Preview {
    AuthenticationView()
}
