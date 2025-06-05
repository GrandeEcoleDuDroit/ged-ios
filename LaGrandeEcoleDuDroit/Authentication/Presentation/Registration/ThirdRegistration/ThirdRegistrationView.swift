import SwiftUI

struct ThirdRegistrationDestination: View {
    @StateObject private var viewModel: ThirdRegistrationViewModel = AuthenticationInjection.shared.resolve(ThirdRegistrationViewModel.self)
    @State private var inputFieldFocused: InputField? = nil
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
    
    @State private var inputFieldFocused: InputField?
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: GedSpacing.medium) {
                Text(getString(.enterEmailPassword))
                    .font(.title3)
                
                OutlineTextField(
                    label: getString(.email),
                    text: $email,
                    inputField: InputField.email,
                    inputFieldFocused: $inputFieldFocused,
                    isDisable: loading,
                    errorMessage: emailError
                )
                .textInputAutocapitalization(.never)
                
                OutlinePasswordTextField(
                    label: getString(.password),
                    text: $password,
                    inputField: InputField.password,
                    inputFieldFocused: $inputFieldFocused,
                    isDisable: loading,
                    errorMessage: passwordError
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            
            if loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .contentShape(Rectangle())
        .onTapGesture { inputFieldFocused = nil }
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
