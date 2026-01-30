import SwiftUI

struct AuthenticationForm: View {
    @Binding var email: String
    @Binding var password: String
    let loading: Bool
    let emailError: String?
    let passwordError: String?
    let errorMessage: String?
    let onForgottenPasswordClick: () -> Void
    let onLoginClick: () -> Void
    let onRegisterClick: () -> Void
    
    var body: some View {
        VStack(spacing: DimensResource.mediumPadding) {
            CredentialsInputs(
                email: $email,
                password: $password,
                loading: loading,
                emailError: emailError,
                passwordError: passwordError,
                errorMessage: errorMessage,
                onForgottenPasswordClick: onForgottenPasswordClick
            )
            
            LoadingButton(
                label: stringResource(.login),
                loading: loading,
                action: onLoginClick
            )
            
            RegistrationText(onRegisterClick: onRegisterClick)
            
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
    let onForgottenPasswordClick: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DimensResource.mediumPadding) {
            OutlinedTextField(
                stringResource(.email),
                text: $email,
                disabled: loading,
                errorMessage: emailError
            )
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            
            OutlinedPasswordTextField(
                stringResource(.password),
                text: $password,
                disabled: loading,
                errorMessage: passwordError
            )
            .textContentType(.password)
            
            if let errorMessage {
                Text(errorMessage)
                    .font(.callout)
                    .foregroundStyle(.error)
            }
            
            Button(stringResource(.forgottenPasswordButtonText), action: onForgottenPasswordClick)
                .font(.callout)
                .fontWeight(.medium)
        }
    }
}

private struct RegistrationText: View {
    let onRegisterClick: () -> Void
    
    var body: some View {
        HStack {
            Text(stringResource(.notRegisterYet))
                .foregroundStyle(Color.primary)
            
            Button(stringResource(.register), action: onRegisterClick)
                .foregroundColor(.gedPrimary)
                .fontWeight(.medium)
        }
        .font(.callout)
    }
}

#Preview {
    AuthenticationForm(
        email: .constant(""),
        password: .constant(""),
        loading: false,
        emailError: nil,
        passwordError: nil,
        errorMessage: nil,
        onForgottenPasswordClick: {}
        , onLoginClick: {},
        onRegisterClick: {}
    )
}
