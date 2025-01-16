import SwiftUI

struct EmailVerificationView: View {
    @StateObject private var emailVerificationViewModel: EmailVerificationViewModel = AuthenticationInjection.shared.resolve(EmailVerificationViewModel.self)
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var isValid = false
    @State private var isAnimating = false
    private let email: String
    
    init(email: String) {
        self.email = email
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            Text(getString(.emailVerificationExplanationBegining))
                .font(.title3)
            
             + Text(email)
                .fontWeight(.semibold)
                .font(.title3)
                
             + Text(getString(.emailVerificationExplanationEnd))
                .font(.title3)
            
            if case .error(let message) = emailVerificationViewModel.authenticationState {
                HStack {
                    Image(systemName: "exclamationmark.octagon")
                    Text(message)
                }
                .foregroundStyle(Color.red)
            }
            
            Image(systemName: "envelope.circle.fill")
                .resizable()
                .scaledToFit()
                .scaleEffect(isAnimating ? 0.4 : 0.35)
                .onAppear() {
                    withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
                        isAnimating = true
                    }
                }
                .foregroundStyle(.gedPrimary)
                .frame(maxHeight: .infinity, alignment: .center)
            
                Button(getString(.finish)) {
                    emailVerificationViewModel.checkVerifiedEmail()
                }
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.gedPrimary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .onAppear {
            emailVerificationViewModel.sendVerificationEmail()
        }
        .navigationTitle(getString(.emailVerificationTitle))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
    }
}

#Preview {
    NavigationStack {
        EmailVerificationView(email: "example@email.com")
    }
}
