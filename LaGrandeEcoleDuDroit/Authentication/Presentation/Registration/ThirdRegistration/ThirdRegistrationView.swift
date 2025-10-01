import SwiftUI

struct ThirdRegistrationDestination: View {
    @StateObject private var viewModel = AuthenticationMainThreadInjector.shared.resolve(ThirdRegistrationViewModel.self)
    @State private var focusedInputField: InputField? = nil
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
        ).onReceive(viewModel.$event) { event in
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

private struct ThirdRegistrationView: View {
    @Binding var email: String
    @Binding var password: String
    let loading: Bool
    let emailError: String?
    let passwordError: String?
    let errorMessage: String?
    let onRegisterClick: () -> Void
    
    @State private var focusedInputField: InputField?
    
    var body: some View {
        ZStack {
            ThirdRegistrationForm(
                email: $email,
                password: $password,
                loading: loading,
                emailError: emailError,
                passwordError: passwordError,
                errorMessage: errorMessage,
                focusedInputField: $focusedInputField
            )
            
            if loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .contentShape(Rectangle())
        .onTapGesture { focusedInputField = nil }
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
            loading: false,
            emailError: nil,
            passwordError: nil,
            errorMessage: nil,
            onRegisterClick: {}
        )
    }
}
