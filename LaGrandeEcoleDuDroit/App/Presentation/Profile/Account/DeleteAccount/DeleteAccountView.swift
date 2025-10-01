import SwiftUI

struct DeleteAccountDestination: View {
    @StateObject private var viewModel = AppMainThreadInjector.shared.resolve(DeleteAccountViewModel.self)
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    
    var body: some View {
        DeleteAccountView(
            email: $viewModel.uiState.email,
            password: $viewModel.uiState.password,
            loading: viewModel.uiState.loading,
            errorMessage: viewModel.uiState.errorMessage,
            onDeleteAccountClick: viewModel.deleteUserAccount
        )
        .onReceive(viewModel.$event) { event in
            if let errorEvent = event as? ErrorEvent {
                errorMessage = errorEvent.message
                showErrorAlert = true
            }
        }
        .alert(
            errorMessage,
            isPresented: $showErrorAlert
        ) {
            Button(getString(.ok)) {
                showErrorAlert = false
            }
        }
    }
}

private struct DeleteAccountView: View {
    @Binding var email: String
    @Binding var password: String
    let loading: Bool
    let errorMessage: String?
    let onDeleteAccountClick: () -> Void
            
    var body: some View {
        VStack(alignment: .leading) {
            Text(getString(.deleteAccountText))
                .padding(.horizontal, GedSpacing.mediumLarge)

            List {
                Section(getString(.enterEmailPassword)) {
                    TextField(
                        getString(.email),
                        text: $email
                    )
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    
                    SecureField(
                        getString(.password),
                        text: $password
                    )
                }
            }
            .frame(maxHeight: 130)
            .scrollContentBackground(.hidden)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.callout)
                    .foregroundStyle(.error)
                    .padding(.horizontal, GedSpacing.mediumLarge)
            }
            
            Button(
                action: onDeleteAccountClick,
                label: {
                    Text(getString(.deleteAccount))
                        .frame(maxWidth: .infinity)
                        .padding(GedSpacing.smallMedium)
                }
            )
            .background(.listRowBackground)
            .foregroundColor(.red)
            .cornerRadius(10)
            .padding(.horizontal, GedSpacing.mediumLarge)
            .padding(.vertical, GedSpacing.small)
        }
        .contentShape(Rectangle())
        .navigationTitle(getString(.deleteAccount))
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.listBackground)
        .loading(loading)
    }
}

#Preview {
    NavigationStack {
        DeleteAccountView(
            email: .constant(""),
            password: .constant(""),
            loading: false,
            errorMessage: nil,
            onDeleteAccountClick: {}
        )
        .background(.listBackground)
    }
}
