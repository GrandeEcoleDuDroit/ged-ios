import SwiftUI

struct AuthenticationDestination: View {
    let onRegisterClick: () -> Void
    let onForgottenPasswordClick: () -> Void
    
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
            onRegisterClick: onRegisterClick,
            onForgottenPasswordClick: onForgottenPasswordClick
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
    let onForgottenPasswordClick: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: DimensResource.largePadding) {
                HeaderSection()
                
                AuthenticationForm(
                    email: $email,
                    password: $password,
                    loading: loading,
                    emailError: emailError,
                    passwordError: passwordError,
                    errorMessage: errorMessage,
                    onForgottenPasswordClick: onForgottenPasswordClick,
                    onLoginClick: onLoginClick,
                    onRegisterClick: onRegisterClick
                )
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.hidden)
    }
}

private struct HeaderSection: View {
    private let imageWidth = UIScreen.main.bounds.width * 0.4
    private let imageHeight = UIScreen.main.bounds.height * 0.2
    
    var body: some View {
        VStack(spacing: DimensResource.smallPadding) {
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

#Preview {
    AuthenticationView(
        email: .constant(""),
        password: .constant(""),
        loading: false,
        emailError: nil,
        passwordError: nil,
        errorMessage: nil,
        onLoginClick: {},
        onRegisterClick: {},
        onForgottenPasswordClick: {}
    )
    .background(.appBackground)
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
