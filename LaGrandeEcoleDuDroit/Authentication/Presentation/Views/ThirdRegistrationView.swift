import SwiftUI

struct ThirdRegistrationView: View {
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var inputFocused: InputField?
    @State private var isValid = false
    
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
                )
                
                FocusableOutlinedPasswordTextField(
                    title: getString(gedString: GedString.password),
                    text: $registrationViewModel.password,
                    defaultFocusValue: InputField.password,
                    inputFocused: $inputFocused
                )
                
                if registrationViewModel.errorMessage != nil {
                    Text(registrationViewModel.errorMessage!)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    NavigationLink(
                        destination: ThirdRegistrationView(),
                        isActive: $isValid
                    ) {
                        Button(action: {
                            isValid = registrationViewModel.validateCredentialInputs()
                        }) {
                            Text(getString(gedString: GedString.next))
                                .tint(Color(GedColor.primary))
                                .font(.title2)
                        }
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
                    BackButton(text: "", action: {
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
