import SwiftUI

struct DeleteAccountDestination: View {
    @StateObject private var viewModel = AppMainThreadInjector.shared.resolve(DeleteAccountViewModel.self)
    
    var body: some View {
        DeleteAccountView(
            password: $viewModel.uiState.password,
            loading: viewModel.uiState.loading,
            errorMessage: viewModel.uiState.errorMessage,
            onDeleteAccountClick: viewModel.deleteUserAccount
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
        Form {
            Text(stringResource(.deleteAccountText))
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            
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
                            .foregroundStyle(Color(UIColor.systemGray))
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
        .navigationTitle(stringResource(.deleteAccount))
        .navigationBarTitleDisplayMode(.inline)
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
        .background(.profileSectionBackground)
    }
}
