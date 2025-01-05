import SwiftUI

struct ThirdRegistrationView: View {
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var inputFieldFocused: InputField?
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            Text(getString(.enterEmailPassword))
                .font(.title3)
            
            FocusableOutlinedTextField(
                title: getString(.email),
                text: $registrationViewModel.email,
                inputField: InputField.email,
                inputFieldFocused: $inputFieldFocused,
                isDisable: isLoading
            )
            
            FocusableOutlinedPasswordTextField(
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
                navigationCoordinator.push(AuthenticationScreen.emailVerification(email: registrationViewModel.email))
            } else if case .loading = state {
                isLoading = true
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .contentShape(Rectangle())
        .onTapGesture { inputFieldFocused = nil }
        .onAppear { registrationViewModel.resetState() }
        .registrationToolbar(step: 3, maxStep: 3)
    }
}

#Preview {
    let mockRegistrationViewModel = AuthenticationDependencyInjectionContainer.shared.resolveWithMock().resolve(RegistrationViewModel.self)!

    NavigationStack {
        ThirdRegistrationView()
            .environmentObject(mockRegistrationViewModel)
            .environmentObject(CommonDependencyInjectionContainer.shared.resolve(NavigationCoordinator.self))
    }
}
