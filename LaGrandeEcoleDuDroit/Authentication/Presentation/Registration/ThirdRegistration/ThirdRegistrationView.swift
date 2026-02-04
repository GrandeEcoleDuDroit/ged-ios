import SwiftUI

struct ThirdRegistrationDestination: View {
    let firstName: String
    let lastName: String
    let schoolLevel: SchoolLevel
    
    @StateObject private var viewModel = AuthenticationMainThreadInjector.shared.resolve(ThirdRegistrationViewModel.self)
    @EnvironmentObject private var appStateManager: AppStateManager

    var body: some View {
        ThirdRegistrationView(
            email: $viewModel.uiState.email,
            password: $viewModel.uiState.password,
            legalNoticeChecked: $viewModel.uiState.legalNoticeChecked,
            loading: viewModel.uiState.loading,
            emailError: viewModel.uiState.emailError,
            passwordError: viewModel.uiState.passwordError,
            errorMessage: viewModel.uiState.errorMessage,
            onEmailChange: viewModel.onEmailChange,
            onRegisterClick: {
                viewModel.register(
                    firstName: firstName,
                    lastName: lastName,
                    schoolLevel: schoolLevel
                )
            }
        )
        .onChange(of: viewModel.uiState.loading) { loading in
            if loading {
                appStateManager.updateState(.registering)
            } else if appStateManager.state == .registering {
                appStateManager.resetState()
            }
        }
    }
}

private struct ThirdRegistrationView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var legalNoticeChecked: Bool
    let loading: Bool
    let emailError: String?
    let passwordError: String?
    let errorMessage: String?
    let onEmailChange: (String) -> Void
    let onRegisterClick: () -> Void
    
    @FocusState private var focusState: RegistrationFocusField?

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DimensResource.mediumPadding) {
                    Text(stringResource(.enterEmailPassword))
                        .font(.title3)
                    
                    FormContent(
                        email: $email,
                        password: $password,
                        legalNoticeChecked: $legalNoticeChecked,
                        loading: loading,
                        focusState: _focusState,
                        emailError: emailError,
                        passwordError: passwordError,
                        errorMessage: errorMessage,
                        onEmailChange: onEmailChange
                    )
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            
            Spacer()
            
            Button(
                action: {
                    focusState = nil
                    onRegisterClick()
                }
            ) {
                if loading {
                    Text(stringResource(.next))
                } else {
                    Text(stringResource(.next))
                        .foregroundStyle(.gedPrimary)
                }
            }
            .fontWeight(.semibold)
            .disabled(loading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .disabled(loading)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(stringResource(.registration))
    }
}

private struct FormContent: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var legalNoticeChecked: Bool
    let loading: Bool
    @FocusState var focusState: RegistrationFocusField?
    let emailError: String?
    let passwordError: String?
    let errorMessage: String?
    let onEmailChange: (String) -> Void
    
    private let legalNoticeUrl = "https://grandeecoledudroit.github.io/ged-website/legal-notice.html"
    
    var body: some View {
        VStack(alignment: .leading, spacing: DimensResource.mediumPadding) {
            OutlinedTextField(
                stringResource(.email),
                text: $email,
                disabled: loading,
                errorMessage: emailError,
                focusState: _focusState,
                field: .email
            )
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            .onChange(of: email, perform: onEmailChange)
            
            OutlinedPasswordTextField(
                stringResource(.password),
                text: $password,
                disabled: loading,
                errorMessage: passwordError,
                focusState: _focusState,
                field: .password
            )
            .textContentType(.password)
            
            HStack {
                CheckBox(checked: legalNoticeChecked)
                    .onTapGesture {
                        legalNoticeChecked.toggle()
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
    }
}

#Preview {
    NavigationStack {
        ThirdRegistrationView(
            email: .constant(""),
            password: .constant(""),
            legalNoticeChecked: .constant(false),
            loading: false,
            emailError: nil,
            passwordError: nil,
            errorMessage: nil,
            onEmailChange: { _ in },
            onRegisterClick: {}
        )
        .background(.appBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
