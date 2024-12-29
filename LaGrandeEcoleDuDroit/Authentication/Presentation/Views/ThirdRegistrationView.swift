import SwiftUI

struct ThirdRegistrationView: View {
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @EnvironmentObject private var coordinator: AuthenticationNavigationCoordinator
    @State private var inputFocused: InputField?
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            Text(getString(.enterEmailPassword))
                .font(.title3)
            
            FocusableOutlinedTextField(
                title: getString(.email),
                text: $registrationViewModel.email,
                defaultFocusValue: InputField.email,
                inputFocused: $inputFocused,
                isDisable: isLoading
            )
            
            FocusableOutlinedPasswordTextField(
                title: getString(.password),
                text: $registrationViewModel.password,
                defaultFocusValue: InputField.password,
                inputFocused: $inputFocused,
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
            
            HStack {
                Spacer()
                
                Button(action: {
                    Task {
                       if registrationViewModel.validateCredentialInputs() {
                           await registrationViewModel.register()
                       }
                   }
                }) {
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
            }
            .padding()
        }
        .onReceive(registrationViewModel.$registrationState) { state in
            if state == .registered {
                coordinator.push(AuthenticationScreen.emailVerification)
            } else if case .loading = state {
                isLoading = true
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .contentShape(Rectangle())
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture { inputFocused = nil }
        .onAppear { registrationViewModel.resetState() }
        .registrationToolbar(step: 3, maxStep: 3)
        .navigationDestination(for: AuthenticationScreen.self) { screen in
            if case .emailVerification = screen {
                EmailVerificationView()
                    .environmentObject(registrationViewModel)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ThirdRegistrationView()
            .environmentObject(DependencyContainer.shared.mockRegistrationViewModel)
            .environmentObject(AuthenticationNavigationCoordinator())
    }
}
