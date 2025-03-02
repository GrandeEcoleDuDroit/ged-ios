import SwiftUI

struct ForgottenPasswordView: View {
    @StateObject private var forgottenPasswordViewModel = AuthenticationInjection.shared.resolve(ForgottenPasswordViewModel.self)
    @State var inputFieldFocused: InputField?
    @State var isLoading: Bool = false
    @State var isInputsFocused: Bool = false
    
    var body: some View {
        VStack(spacing: GedSpacing.medium) {
            Text(getString(.forgottenPassword))
                .font(.title)
            
            EmailTextField(
                title: getString(.email),
                text: $forgottenPasswordViewModel.email,
                inputField: InputField.email,
                inputFieldFocused: $inputFieldFocused,
                isDisable: isLoading
            )
            .simultaneousGesture(TapGesture().onEnded({
                isInputsFocused = true
            }))
        }
        .padding()
        .onChange(of: isInputsFocused) { isFocused in
            if !isFocused {
                inputFieldFocused = nil
            }
        }
        .onTapGesture { isInputsFocused = false }
    }
}

#Preview {
    ForgottenPasswordView()
}
