import SwiftUI

struct ThirdRegistrationForm: View {
    @Binding var email: String
    @Binding var password: String
    let loading: Bool
    let emailError: String?
    let passwordError: String?
    let errorMessage: String?
    let legalNoticeChecked: Bool
    let onLegalNoticeCheckedChange: (Bool) -> Void
    @FocusState var focusState: Field?
    
    private let legalNoticeUrl = "https://grandeecoledudroit.github.io/ged-website/legal-notice.html"
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            Text(getString(.enterEmailPassword))
                .font(.title3)
            
            OutlineTextField(
                label: getString(.email),
                text: $email,
                isDisable: loading,
                errorMessage: emailError,
                focusState: _focusState,
                field: .email
            )
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            
            OutlinePasswordTextField(
                label: getString(.password),
                text: $password,
                isDisable: loading,
                errorMessage: passwordError,
                focusState: _focusState,
                field: .password
            )
            .textContentType(.password)
            
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
        legalNoticeChecked: false,
        onLegalNoticeCheckedChange: { _ in },
        focusState: FocusState<Field?>()
    )
}
