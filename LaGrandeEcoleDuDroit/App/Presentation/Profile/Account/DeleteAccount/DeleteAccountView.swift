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
                Button(getString(.ok)) {
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
            Text(getString(.deleteAccountText))
                .padding(.horizontal, GedSpacing.mediumLarge)
            
            Form {
                Section(getString(.enterPassword)) {
                    if showPassword {
                        HStack {
                            TextField(
                                getString(.password),
                                text: $password
                            )
                            .textContentType(.password)

                            Image(systemName: "eye")
                                .foregroundColor(.iconInput)
                                .onTapGesture {
                                    showPassword = false
                                }
                        }
                    } else {
                        HStack {
                            SecureField(
                                getString(.password),
                                text: $password
                            )
                            .textContentType(.password)
                            
                            Image(systemName: "eye.slash")
                                .foregroundColor(.iconInput)
                                .onTapGesture {
                                    showPassword = true
                                }
                        }
                    }
                }
            }
            .frame(maxHeight: 90)
            .scrollContentBackground(.hidden)
            
            if let errorMessage {
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
            .foregroundStyle(.red)
            .clipShape(.rect(cornerRadius: 10))
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
            password: .constant(""),
            loading: false,
            errorMessage: nil,
            onDeleteAccountClick: {}
        )
    }
}
