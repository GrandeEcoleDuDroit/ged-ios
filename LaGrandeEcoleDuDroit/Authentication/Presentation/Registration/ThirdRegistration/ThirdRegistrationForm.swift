import SwiftUI

struct ThirdRegistrationForm: View {
    let email: String
    let onEmailChange: (String) -> String
    let password: String
    let onPasswordChange: (String) -> Void
    let loading: Bool
    let emailError: String?
    let passwordError: String?
    let errorMessage: String?
    let legalNoticeChecked: Bool
    let onLegalNoticeCheckedChange: (Bool) -> Void
    
    @FocusState var focusState: Field?
    
    private let legalNoticeUrl = "https://grandeecoledudroit.github.io/ged-website/legal-notice.html"
    
    var body: some View {
        VStack(alignment: .leading, spacing: Dimens.mediumPadding) {
            Text(stringResource(.enterEmailPassword))
                .font(.title3)
            
            OutlinedTextField(
                initialText: email,
                onTextChange: onEmailChange,
                placeHolder: stringResource(.email),
                disabled: loading,
                errorMessage: emailError
            )
            .setTextFieldFocusState(focusState: _focusState, field: .email)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            
            OutlinedPasswordTextField(
                label: stringResource(.password),
                text: password,
                onTextChange: onPasswordChange,
                isDisable: loading,
                errorMessage: passwordError,
                focusState: _focusState,
                field: .password
            )
            .textContentType(.password)
            
            HStack {
                CheckBox(
                    checked: legalNoticeChecked
                ).onTapGesture {
                    onLegalNoticeCheckedChange(!legalNoticeChecked)
                }
                
                Group {
                    Text(stringResource(.agreeTermsPrivacyBeginningText))
                    + Text(" ")
                    + Text(.init("[\(stringResource(.termsAndPrivacy))](\(legalNoticeUrl))")).underline()
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
        email: "",
        onEmailChange: { _ in "" },
        password: "",
        onPasswordChange: { _ in },
        loading: false,
        emailError: nil,
        passwordError: nil,
        errorMessage: nil,
        legalNoticeChecked: false,
        onLegalNoticeCheckedChange: { _ in },
        focusState: FocusState<Field?>()
    )
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
