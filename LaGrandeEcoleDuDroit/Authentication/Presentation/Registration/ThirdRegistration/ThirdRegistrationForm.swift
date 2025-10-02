import SwiftUI

struct ThirdRegistrationForm: View {
    @Binding var email: String
    @Binding var password: String
    let loading: Bool
    let emailError: String?
    let passwordError: String?
    let errorMessage: String?
    @Binding var focusedInputField: InputField?
    let legalNoticeChecked: Bool
    let onLegalNoticeCheckedChange: (Bool) -> Void
    private let legalNoticeUrl = "https://grandeecoledudroit.github.io/ged-website/legal-notice.html"
    
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
            
            HStack {
                CheckBox(
                    checked: legalNoticeChecked,
                    onCheckedChange: onLegalNoticeCheckedChange
                )
                
                Group {
                    Text(getString(.agreeTermsPrivacyBeginningText))
                    + Text(" ")
                    + Text(.init("[\(getString(.termsAndPrivacy))](\(legalNoticeUrl))"))
                        .underline()
                    + Text(".")
                }
                .font(.footnote)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.callout)
                    .foregroundStyle(.error)
            }
        }
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
        legalNoticeChecked: false,
        onLegalNoticeCheckedChange: { _ in }
    )
}
