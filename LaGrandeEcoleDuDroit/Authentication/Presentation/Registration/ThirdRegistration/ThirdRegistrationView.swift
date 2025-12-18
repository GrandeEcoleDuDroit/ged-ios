import SwiftUI

struct ThirdRegistrationDestination: View {
    let firstName: String
    let lastName: String
    let schoolLevel: SchoolLevel
    
    @StateObject private var viewModel = AuthenticationMainThreadInjector.shared.resolve(ThirdRegistrationViewModel.self)
    @State private var showErrorAlert = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        ThirdRegistrationView(
            email: $viewModel.uiState.email,
            password: $viewModel.uiState.password,
            legalNoticeChecked: $viewModel.uiState.legalNoticeChecked,
            loading: viewModel.uiState.loading,
            emailError: viewModel.uiState.emailError,
            passwordError: viewModel.uiState.passwordError,
            errorMessage: viewModel.uiState.errorMessage,
            onRegisterClick: {
                viewModel.register(
                    firstName: firstName,
                    lastName: lastName,
                    schoolLevel: schoolLevel
                )
            }
        )
        .onReceive(viewModel.$event) { event in
            if let errorEvent = event as? ErrorEvent {
                errorMessage = errorEvent.message
                showErrorAlert = true
            }
        }
        .alert(
            errorMessage,
            isPresented: $showErrorAlert,
            actions: {
                Button(stringResource(.ok), role: .cancel) {
                    showErrorAlert = false
                }
            }
        )
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
    let onRegisterClick: () -> Void
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: Dimens.mediumPadding) {
                    FormContent(
                        email: $email,
                        password: $password,
                        legalNoticeChecked: $legalNoticeChecked,
                        loading: loading,
                        emailError: emailError,
                        passwordError: passwordError,
                        errorMessage: errorMessage,
                    )
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
            
            Spacer()
            
            Button(action: onRegisterClick) {
                if loading {
                    Text(stringResource(.next))
                } else {
                    Text(stringResource(.next))
                        .foregroundStyle(.gedPrimary)
                }
            }
            .disabled(loading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .loading(loading)
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
    let emailError: String?
    let passwordError: String?
    let errorMessage: String?
    
    private let legalNoticeUrl = "https://grandeecoledudroit.github.io/ged-website/legal-notice.html"
    
    var body: some View {
        VStack(alignment: .leading, spacing: Dimens.mediumPadding) {
            Text(stringResource(.enterEmailPassword))
                .font(.title3)
            
            OutlinedTextField(
                stringResource(.email),
                text: $email,
                disabled: loading,
                errorMessage: emailError
            )
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            
            OutlinedPasswordTextField(
                stringResource(.password),
                text: $password,
                disabled: loading,
                errorMessage: passwordError
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
            onRegisterClick: {}
        )
        .background(.appBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
