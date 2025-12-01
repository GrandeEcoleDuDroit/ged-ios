import SwiftUI

struct ThirdRegistrationDestination: View {
    @StateObject private var viewModel = AuthenticationMainThreadInjector.shared.resolve(ThirdRegistrationViewModel.self)
    @State private var isLoading: Bool = false
    @State private var showErrorAlert = false
    @State private var errorMessage: String = ""
    
    let firstName: String
    let lastName: String
    let schoolLevel: SchoolLevel
    
    var body: some View {
        ThirdRegistrationView(
            email: viewModel.uiState.email,
            onEmailChange: viewModel.onEmailChange,
            password: viewModel.uiState.password,
            onPasswordChange: viewModel.onPasswordChange,
            legalNoticeChecked: viewModel.uiState.legalNoticeChecked,
            onLegalNoticeCheckedChange: viewModel.onLegalNoticeCheckedChange,
            loading: viewModel.uiState.loading,
            emailError: viewModel.uiState.emailError,
            passwordError: viewModel.uiState.passwordError,
            errorMessage: viewModel.uiState.errorMessage,
            onRegisterClick: {
                viewModel.register(
                    firstName: firstName,
                    lastName: lastName,
                    schoolLevel: schoolLevel
                )
            }
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

private struct ThirdRegistrationView: View {
    let email: String
    let onEmailChange: (String) -> String
    let password: String
    let onPasswordChange: (String) -> Void
    let legalNoticeChecked: Bool
    let onLegalNoticeCheckedChange: (Bool) -> Void
    let loading: Bool
    let emailError: String?
    let passwordError: String?
    let errorMessage: String?
    let onRegisterClick: () -> Void
    
    @FocusState private var focusState: Field?

    var body: some View {
        VStack(spacing: Dimens.mediumPadding) {
            ThirdRegistrationForm(
                email: email,
                onEmailChange: onEmailChange,
                password: password,
                onPasswordChange: onPasswordChange,
                loading: loading,
                emailError: emailError,
                passwordError: passwordError,
                errorMessage: errorMessage,
                legalNoticeChecked: legalNoticeChecked,
                onLegalNoticeCheckedChange: onLegalNoticeCheckedChange,
                focusState: _focusState
            )
            
            if loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarTitleDisplayMode(.inline)
        .contentShape(Rectangle())
        .onTapGesture { focusState = nil }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(stringResource(.registration))
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: onRegisterClick,
                    label: {
                        if loading {
                            Text(stringResource(.next))
                                .fontWeight(.semibold)
                        } else {
                            Text(stringResource(.next))
                                .fontWeight(.semibold)
                                .foregroundStyle(.gedPrimary)
                        }
                    }
                )
                .disabled(loading)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ThirdRegistrationView(
            email: "",
            onEmailChange: { _ in "" },
            password: "",
            onPasswordChange: { _ in },
            legalNoticeChecked: false,
            onLegalNoticeCheckedChange: { _ in },
            loading: false,
            emailError: nil,
            passwordError: nil,
            errorMessage: nil,
            onRegisterClick: {}
        )
        .background(Color.background)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
