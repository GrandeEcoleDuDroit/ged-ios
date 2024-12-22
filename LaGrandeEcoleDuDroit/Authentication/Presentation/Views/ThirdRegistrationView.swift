import SwiftUI

struct ThirdRegistrationView: View {
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isActive: Bool = false
    @State private var inputFocused: InputField?
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            Text(getString(.enterEmailPassword))
                .font(.title2)
            
            FocusableOutlinedTextField(
                title: getString(.email),
                text: $registrationViewModel.email,
                defaultFocusValue: InputField.email,
                inputFocused: $inputFocused
            ).disabled(registrationViewModel.registrationState == .loading)
            
            FocusableOutlinedPasswordTextField(
                title: getString(.password),
                text: $registrationViewModel.password,
                defaultFocusValue: InputField.password,
                inputFocused: $inputFocused
            ).disabled(registrationViewModel.registrationState == .loading)
            
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
            
            if registrationViewModel.registrationState == .loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button(
                    action: {
                        Task {
                            if registrationViewModel.validateCredentialInputs() {
                                await registrationViewModel.register()
                            }
                        }
                    },
                    label: {
                        Text(getString(.next))
                            .font(.title2)
                    }
                )
                .disabled(registrationViewModel.registrationState == .loading)
                .overlay {
                    NavigationLink(
                        destination: EmailVerificationView()
                            .environmentObject(registrationViewModel),
                        isActive: $isActive,
                        label: { EmptyView() }
                    )
                }
            }
            .onReceive(registrationViewModel.$registrationState) { state in
                if state == .registered {
                    isActive = true
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemBackground))
        .padding()
        .onTapGesture {
            inputFocused = nil
        }
        .onAppear {
            registrationViewModel.resetState()
        }
        .registrationToolbar(step: 3, maxStep: 3)
    }
}

#Preview {
    ThirdRegistrationView()
        .environmentObject(DependencyContainer.shared.mockRegistrationViewModel)
}
