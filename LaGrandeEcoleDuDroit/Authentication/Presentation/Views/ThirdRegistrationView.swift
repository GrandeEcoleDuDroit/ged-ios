import SwiftUI

struct ThirdRegistrationView: View {
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @State private var inputFieldFocused: InputField?
    @State private var isLoading: Bool = false
    @State private var navigateToEmailVerification: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            Text(getString(.enterEmailPassword))
                .font(.title3)
            
            EmailTextField(
                title: getString(.email),
                text: $registrationViewModel.email,
                inputField: InputField.email,
                inputFieldFocused: $inputFieldFocused,
                isDisable: isLoading
            )
            .textInputAutocapitalization(.never)
            
            PasswordTextField(
                title: getString(.password),
                text: $registrationViewModel.password,
                inputField: InputField.password,
                inputFieldFocused: $inputFieldFocused,
                isDisable: isLoading
            )
                        
            HStack {
                Image(systemName: "info.circle")
                    .foregroundStyle(Color(UIColor.lightGray))
                
                Text(getString(.sendEmailVerificationCaption))
                    .font(.caption)
                    .foregroundStyle(Color(UIColor.lightGray))
            }
            
            if case .error(let message) = registrationViewModel.registrationState {
                Text(message)
                    .foregroundStyle(.red)
            }
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            
            Spacer()
           
            Button(
                action: {
                   if registrationViewModel.validateCredentialInputs() {
                       registrationViewModel.register()
                   }
                }
            ) {
                if isLoading || !registrationViewModel.credentialInputsNotEmpty() {
                    Text(getString(.next))
                       .font(.title2)
                       .fontWeight(.medium)
                } else {
                    Text(getString(.next))
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.gedPrimary)
                }
            }
            .disabled(isLoading || !registrationViewModel.credentialInputsNotEmpty())
            .padding()
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .onReceive(registrationViewModel.$registrationState) { state in
            if state == .registered {
                navigateToEmailVerification = true
            } else if case .loading = state {
                isLoading = true
            } else {
                isLoading = false
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .contentShape(Rectangle())
        .onTapGesture { inputFieldFocused = nil }
        .onAppear { registrationViewModel.resetState() }
        .registrationToolbar(step: 3, maxStep: 3)
        .navigationDestination(isPresented: $navigateToEmailVerification) {
            EmailVerificationView(email: registrationViewModel.email)
        }
    }
}

#Preview {
    let mockRegistrationViewModel = AuthenticationInjection.shared.resolveWithMock().resolve(RegistrationViewModel.self)!

    NavigationStack {
        ThirdRegistrationView()
            .environmentObject(mockRegistrationViewModel)
            .environmentObject(CommonInjection.shared.resolve(NavigationCoordinator.self))
    }
}
