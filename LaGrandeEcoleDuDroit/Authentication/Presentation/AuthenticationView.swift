import SwiftUI

struct AuthenticationDestination: View {
    let onRegisterClick: () -> Void
    
    @StateObject private var viewModel = AuthenticationMainThreadInjector.shared.resolve(AuthenticationViewModel.self)
    @State private var showErrorAlert = false
    @State private var errorMessage: String = ""
    
    var body: some View {            
        AuthenticationView(
            email: $viewModel.uiState.email,
            password: $viewModel.uiState.password,
            loading: viewModel.uiState.loading,
            emailError: viewModel.uiState.emailError,
            passwordError: viewModel.uiState.passwordError,
            errorMessage: viewModel.uiState.errorMessage,
            onLoginClick: viewModel.login,
            onRegisterClick: onRegisterClick
        )
        .onReceive(viewModel.$event) { event in
            if let errorEvent = event as? ErrorEvent {
                errorMessage = errorEvent.message
                showErrorAlert = true
            }
        }
        .alert(errorMessage, isPresented: $showErrorAlert) {
            Button(getString(.ok), role: .cancel) {
                showErrorAlert = false
            }
        }
    }
}

private struct AuthenticationView: View {
    @Binding var email: String
    @Binding var password: String
    @State private var focusedInputField: InputField?
    let loading: Bool
    let emailError: String?
    let passwordError: String?
    let errorMessage: String?
    let onLoginClick: () -> Void
    let onRegisterClick: () -> Void
        
    var body: some View {
        VStack(spacing: GedSpacing.large) {
            HeaderSection()
            
            CredentialsInputs(
                email: $email,
                password: $password,
                loading: loading,
                emailError: emailError,
                passwordError: passwordError,
                errorMessage: errorMessage,
                focusedInputField: $focusedInputField
            )
            .padding(.top, GedSpacing.medium)
            
            Buttons(
                loading: loading,
                onLoginClick: onLoginClick,
                onRegisterClick: onRegisterClick
            )
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .contentShape(Rectangle())
        .onTapGesture { focusedInputField = nil }
    }
}

private struct HeaderSection: View {
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
    @Binding var email: String
    @Binding var password: String
    let loading: Bool
    let emailError: String?
    let passwordError: String?
    let errorMessage: String?
    @Binding var focusedInputField: InputField?
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            OutlineTextField(
                label: getString(.email),
                text: $email,
                inputField: InputField.email,
                focusedInputField: $focusedInputField,
                isDisable: loading,
                errorMessage: emailError
            )
            .textInputAutocapitalization(.never)
            
            OutlinePasswordTextField(
                label: getString(.password),
                text: $password,
                inputField: InputField.password,
                focusedInputField: $focusedInputField,
                isDisable: loading,
                errorMessage: passwordError
            )
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.callout)
                    .foregroundStyle(.error)
            }
        }
    }
}

private struct Buttons: View {
    let loading: Bool
    let onLoginClick: () -> Void
    let onRegisterClick: () -> Void
    
    var body: some View {
        VStack(spacing: GedSpacing.medium) {
            LoadingButton(
                label: getString(.login),
                onClick: onLoginClick,
                isLoading: loading
            )
            
            HStack {
                Text(getString(.notRegisterYet))
                    .foregroundStyle(Color.primary)
                
                Button(
                    action: onRegisterClick,
                    label: {
                        Text(getString(.register))
                            .foregroundColor(.gedPrimary)
                            .fontWeight(.semibold)
                    }
                )
            }
        }
    }
}

#Preview {
    AuthenticationView(
        email: .constant(""),
        password: .constant(""),
        loading: false,
        emailError: nil,
        passwordError: nil,
        errorMessage: "",
        onLoginClick: {},
        onRegisterClick: {}
    )
    .background(Color.background)
}
