import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var forgotPasswordViewModel = AuthenticationInjection.shared.resolve(ForgotPasswordViewModel.self)
    @State private var inputFieldFocused: InputField?
    @State private var isLoading: Bool = false
    @State private var isInputsFocused: Bool = false
    @State private var showToast: Bool = false
    
    private let imageWidth = UIScreen.main.bounds.width * 0.3
    private let imageHeight = UIScreen.main.bounds.height * 0.2
    
    var body: some View {
        VStack(spacing: GedSpacing.medium) {
            Text(getString(.forgotPasswordDescription))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            FillTextField(
                title: getString(.email),
                text: $forgotPasswordViewModel.email,
                inputField: InputField.email,
                inputFieldFocused: $inputFieldFocused,
                isDisable: isLoading
            )
            .simultaneousGesture(TapGesture().onEnded({
                isInputsFocused = true
            }))
            .textInputAutocapitalization(.never)
            
            if case .error(let message) = forgotPasswordViewModel.screenState {
                Text(message)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            LoadingButton(
                label: getString(.send),
                onClick: {
                    if forgotPasswordViewModel.validateInput() {
                        forgotPasswordViewModel.resetPassword()
                    }
                },
                isLoading: isLoading
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .onChange(of: isInputsFocused) { isFocused in
            if !isFocused {
                inputFieldFocused = nil
            }
        }
        .onTapGesture { isInputsFocused = false }
        .onReceive(forgotPasswordViewModel.$screenState) { state in
            isLoading = state == .loading
            showToast = state == .emailSent
        }
        .navigationTitle(getString(.forgotPassword))
        .navigationBarTitleDisplayMode(.inline)
        .toast(isPresented: $showToast, message: getString(.forgotPasswordSuccess))
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordView()
    }
}
