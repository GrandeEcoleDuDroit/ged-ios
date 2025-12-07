import SwiftUI

struct AuthenticationDestination: View {
    let onRegisterClick: () -> Void
    
    @StateObject private var viewModel = AuthenticationMainThreadInjector.shared.resolve(AuthenticationViewModel.self)
    @State private var showErrorAlert = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        AuthenticationView(
            email: viewModel.uiState.email,
            onEmailChange: viewModel.onEmailChange,
            password: viewModel.uiState.password,
            onPasswordChange: viewModel.onPasswordChange,
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
        .alert(
            errorMessage,
            isPresented: $showErrorAlert,
            actions: {
                Button(stringResource(.ok), role: .cancel) {
                    showErrorAlert = false
                }
            }
        )
    }
}

private struct AuthenticationView: View {
    let email: String
    let onEmailChange: (String) -> String
    let password: String
    let onPasswordChange: (String) -> Void
    let loading: Bool
    let emailError: String?
    let passwordError: String?
    let errorMessage: String?
    let onLoginClick: () -> Void
    let onRegisterClick: () -> Void
    
    @FocusState private var focusState: Field?
        
    var body: some View {
        VStack(spacing: Dimens.largePadding) {
            HeaderSection()
            
            CredentialsInputs(
                email: email,
                onEmailChange: onEmailChange,
                password: password,
                onPasswordChange: onPasswordChange,
                loading: loading,
                emailError: emailError,
                passwordError: passwordError,
                errorMessage: errorMessage,
                focusState: _focusState
            )
            .padding(.top, Dimens.mediumPadding)
            
            Buttons(
                loading: loading,
                onLoginClick: onLoginClick,
                onRegisterClick: onRegisterClick
            )
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .contentShape(Rectangle())
        .onTapGesture { focusState = nil }
    }
}

private struct HeaderSection: View {
    private let imageWidth = UIScreen.main.bounds.width * 0.4
    private let imageHeight = UIScreen.main.bounds.height * 0.2
    
    var body: some View {
        VStack(spacing: Dimens.smallPadding) {
            Image(.gedLogo)
                .resizable()
                .scaledToFit()
                .frame(width: imageWidth, height: imageHeight)
            
            Text(stringResource(.appName))
                .font(.title)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(stringResource(.authenticationPageSubtitle))
                .font(.body)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

private struct CredentialsInputs: View {
    let email: String
    let onEmailChange: (String) -> String
    let password: String
    let onPasswordChange: (String) -> Void
    let loading: Bool
    let emailError: String?
    let passwordError: String?
    let errorMessage: String?
    @FocusState var focusState: Field?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Dimens.mediumPadding) {
            OutlinedTextField(
                initialText: email,
                onTextChange: onEmailChange,
                placeHolder: stringResource(.email),
                disabled: loading,
                errorMessage: emailError
            )
            .setTextFieldFocusState(focusState: _focusState, field: .email)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            
            OutlinedPasswordTextField(
                label: stringResource(.password),
                text: password,
                onTextChange: onPasswordChange,
                isDisable: loading,
                errorMessage: passwordError
            )
            .setTextFieldFocusState(focusState: _focusState, field: .password)
            .textContentType(.password)
            
            if let errorMessage {
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
        VStack(spacing: Dimens.mediumPadding) {
            LoadingButton(
                label: stringResource(.login),
                loading: loading,
                action: onLoginClick
            )
            
            HStack {
                Text(stringResource(.notRegisterYet))
                    .foregroundStyle(Color.primary)
                
                Button(
                    action: onRegisterClick,
                    label: {
                        Text(stringResource(.register))
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
        email: "",
        onEmailChange: { _ in "" },
        password: "",
        onPasswordChange: { _ in },
        loading: false,
        emailError: nil,
        passwordError: nil,
        errorMessage: "",
        onLoginClick: {},
        onRegisterClick: {}
    )
    .background(.appBackground)
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
