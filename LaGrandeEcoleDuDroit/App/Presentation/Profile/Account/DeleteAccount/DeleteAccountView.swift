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
        VStack(alignment: .leading) {
            Text(stringResource(.deleteAccountText))
                .padding(.horizontal, Dimens.mediumLargePadding)
            
            Form {
                Section(
                    content: {
                        HStack {
                            if showPassword {
                                TextField(
                                    stringResource(.password),
                                    text: $password
                                )
                                .textContentType(.password)
                            } else {
                                SecureField(
                                    stringResource(.password),
                                    text: $password
                                )
                                .textContentType(.password)
                            }
                            
                            Image(systemName: showPassword ? "eye" : "eye.slash")
                                .foregroundStyle(.onSurfaceVariant)
                                .onTapGesture {
                                    showPassword.toggle()
                                }
                        }
                    },
                    header: { Text(stringResource(.enterPassword)) },
                    footer: {
                        if let errorMessage {
                            Text(errorMessage)
                                .foregroundStyle(.error)
                        } else {
                            EmptyView()
                        }
                    }
                )
                
                Button(
                    stringResource(.deleteAccount),
                    action: onDeleteAccountClick
                )
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .scrollContentBackground(.hidden)
            .scrollDisabled(true)
        }
        .navigationTitle(stringResource(.deleteAccount))
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.profileSectionBackground)
        .loading(loading)
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
    }
}
