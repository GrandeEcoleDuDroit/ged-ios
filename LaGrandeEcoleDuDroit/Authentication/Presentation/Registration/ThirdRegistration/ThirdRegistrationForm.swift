import SwiftUI

struct ThirdRegistrationForm: View {
    @Binding var email: String
    @Binding var password: String
    let loading: Bool
    let emailError: String?
    let passwordError: String?
    let errorMessage: String?
    @Binding var focusedInputField: InputField?
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            Text(getString(.enterEmailPassword))
                .font(.title3)
            
            OutlineTextField(
                label: getString(.email),
                text: $email,
                inputField: InputField.email,
                focusedInputField: $focusedInputField,
                isDisable: loading,
                errorMessage: emailError
            )
            .textInputAutocapitalization(.never)
            
            OutlinePasswordTextField(
                label: getString(.password),
                text: $password,
                inputField: InputField.password,
                focusedInputField: $focusedInputField,
                isDisable: loading,
                errorMessage: passwordError
            )
            
            if let errorMessage {
                Text(errorMessage)
                    .font(.callout)
                    .foregroundStyle(.error)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
    }
}

#Preview {
    ThirdRegistrationForm(
        email: .constant(""),
        password: .constant(""),
        loading: false,
        emailError: nil,
        passwordError: nil,
        errorMessage: nil,
        focusedInputField: .constant(nil),
    )
}
