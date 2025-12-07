import SwiftUI

struct DeleteAccountDestination: View {
    @StateObject private var viewModel = AppMainThreadInjector.shared.resolve(DeleteAccountViewModel.self)
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    
    var body: some View {
        DeleteAccountView(
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
            isPresented: $showErrorAlert,
            actions: {
                Button(stringResource(.ok)) {
                    showErrorAlert = false
                }
            }
        )
    }
}

private struct DeleteAccountView: View {
    @Binding var password: String
    let loading: Bool
    let errorMessage: String?
    let onDeleteAccountClick: () -> Void
    
    @State private var showPassword: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Dimens.largePadding) {
            Text(stringResource(.deleteAccountText))
            
            OutlinedPasswordTextField(
                label: stringResource(.password),
                text: password,
                onTextChange: { password = $0 },
                errorMessage: errorMessage
            )
            
            Button(action: onDeleteAccountClick) {
                Text(stringResource(.deleteAccount))
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .foregroundStyle(.white)
                    .background(.red)
                    .clipShape(.rect(cornerRadius: 30))
            }
        }
        .padding(.horizontal)
        .loading(loading)
        .navigationTitle(stringResource(.deleteAccount))
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    NavigationStack {
        DeleteAccountView(
            password: .constant(""),
            loading: false,
            errorMessage: nil,
            onDeleteAccountClick: {}
        )
        .background(.profileSectionBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
