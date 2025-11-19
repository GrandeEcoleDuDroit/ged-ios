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
    @Binding var email: String
    @Binding var password: String
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
                email: $email,
                password: $password,
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
    @Binding var email: String
    @Binding var password: String
    let loading: Bool
    let emailError: String?
    let passwordError: String?
    let errorMessage: String?
    @FocusState var focusState: Field?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Dimens.mediumPadding) {
            OutlineTextField(
                label: stringResource(.email),
                text: $email,
                isDisable: loading,
                errorMessage: emailError,
                focusState: _focusState,
                field: .email
            )
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            
            OutlinePasswordTextField(
                label: stringResource(.password),
                text: $password,
                isDisable: loading,
                errorMessage: passwordError,
                focusState: _focusState,
                field: .password
            )
            
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
                onClick: onLoginClick,
                isLoading: loading
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
