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
            email: $viewModel.uiState.email,
            password: $viewModel.uiState.password,
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
                Button(getString(.ok), role: .cancel) {
                    showErrorAlert = false
                }
            }
        )
    }
}

private struct ThirdRegistrationView: View {
    @Binding var email: String
    @Binding var password: String
    let legalNoticeChecked: Bool
    let onLegalNoticeCheckedChange: (Bool) -> Void
    let loading: Bool
    let emailError: String?
    let passwordError: String?
    let errorMessage: String?
    let onRegisterClick: () -> Void
    
    @FocusState private var focusState: Field?

    var body: some View {
        VStack(spacing: GedSpacing.medium) {
            ThirdRegistrationForm(
                email: $email,
                password: $password,
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
                Text(getString(.registration))
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: onRegisterClick,
                    label: {
                        if loading {
                            Text(getString(.next))
                                .fontWeight(.semibold)
                        } else {
                            Text(getString(.next))
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
            email: .constant(""),
            password: .constant(""),
            legalNoticeChecked: false,
            onLegalNoticeCheckedChange: { _ in },
            loading: false,
            emailError: nil,
            passwordError: nil,
            errorMessage: nil,
            onRegisterClick: {}
        )
    }
}
