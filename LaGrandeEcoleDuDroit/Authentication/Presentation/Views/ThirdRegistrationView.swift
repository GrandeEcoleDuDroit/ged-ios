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
            
            FillTextField(
                title: getString(.email),
                text: $registrationViewModel.email,
                inputField: InputField.email,
                inputFieldFocused: $inputFieldFocused,
                isDisable: isLoading
            )
            .textInputAutocapitalization(.never)
            
            FillPasswordTextField(
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
            
            if case .error(let message) = registrationViewModel.screenState {
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
        .onReceive(registrationViewModel.$screenState) { state in
            navigateToEmailVerification = state == .registered
            isLoading = state == .loading
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
   NavigationStack {
        ThirdRegistrationView()
            .environmentObject(
                AuthenticationInjection.shared.resolveWithMock().resolve(RegistrationViewModel.self)!
            )
    }
}
