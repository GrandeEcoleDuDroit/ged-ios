import SwiftUI

struct ForgottenPasswordDestination: View {
    @StateObject private var viewModel = AuthenticationMainThreadInjector.shared.resolve(ForgottenPasswordViewModel.self)
    
    var body: some View {
        ForgottenPasswordView(
            email: $viewModel.uiState.email,
            loading: viewModel.uiState.loading,
            emailError: viewModel.uiState.emailError,
            errorMessage: viewModel.uiState.errorMessage,
            successMessage: viewModel.uiState.successMessage,
            onSendResetEmailClick: viewModel.resetEmail
        )
    }
}

private struct ForgottenPasswordView: View {
    @Binding var email: String
    let loading: Bool
    let emailError: String?
    let errorMessage: String?
    let successMessage: String?
    let onSendResetEmailClick: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DimensResource.mediumPadding) {
                Text(stringResource(.enterEmail))
                    .font(.title3)
                
                OutlinedTextField(
                    stringResource(.email),
                    text: $email,
                    disabled: loading,
                    errorMessage: emailError
                )
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                
                if let errorMessage {
                    Text(errorMessage)
                        .font(.callout)
                        .foregroundStyle(.error)
                }
            
                LoadingButton(
                    label: stringResource(.send),
                    loading: loading,
                    action: onSendResetEmailClick
                )
                
                if let successMessage {
                    Text(successMessage)
                        .font(.callout)
                }
            }
            .padding(.horizontal)
        }
        .disabled(loading)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(stringResource(.forgottenPassword))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ForgottenPasswordView(
            email: .constant(""),
            loading: false,
            emailError: nil,
            errorMessage: nil,
            successMessage: nil,
            onSendResetEmailClick: {}
        )
        .background(.appBackground)
    }
}
