import SwiftUI

struct ThirdRegistrationView: View {
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isActive: Bool = false
    @State private var inputFocused: InputField?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: GedSpacing.medium) {
                Text(getString(gedString: GedString.enter_email_password))
                    .font(.title2)
                
                FocusableOutlinedTextField(
                    title: getString(gedString: GedString.email),
                    text: $registrationViewModel.email,
                    defaultFocusValue: InputField.email,
                    inputFocused: $inputFocused
                ).disabled(registrationViewModel.registrationState == .loading)
                
                FocusableOutlinedPasswordTextField(
                    title: getString(gedString: GedString.password),
                    text: $registrationViewModel.password,
                    defaultFocusValue: InputField.password,
                    inputFocused: $inputFocused
                ).disabled(registrationViewModel.registrationState == .loading)
                
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundStyle(Color(UIColor.lightGray))
                    
                    Text(getString(gedString: GedString.send_email_verification_caption))
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
                    NavigationLink(
                        destination: EmailVerificationView()
                            .environmentObject(registrationViewModel),
                        isActive: $isActive
                    ) {
                        Button(action: {
                            if registrationViewModel.validateCredentialInputs() {
                                registrationViewModel.register()
                            }
                        }) {
                            Text(getString(gedString: GedString.next))
                                .tint(Color(GedColor.primary))
                                .font(.title2)
                        }.disabled(registrationViewModel.registrationState == .loading)
                    }
                }
                .onReceive(registrationViewModel.$registrationState) { state in
                    if state == .registered {
                        isActive = true
                    }
                }
                .padding()
            }
            .navigationTitle(getString(gedString: GedString.registration)).navigationBarTitleDisplayMode(.inline)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(UIColor.systemBackground))
            .padding()
            .onTapGesture {
                inputFocused = nil
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton(action: {
                        presentationMode.wrappedValue.dismiss()
                    })
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Text(getString(gedString: GedString.registration_step, 3, registrationViewModel.maxStep))
                        .foregroundStyle(.gray)
                }
                
            }
        }.navigationBarBackButtonHidden()
    }
}

#Preview {
    ThirdRegistrationView()
        .environmentObject(RegistrationViewModel())
}
