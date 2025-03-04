import SwiftUI

struct EmailVerificationView: View {
    @StateObject private var emailVerificationViewModel: EmailVerificationViewModel = AuthenticationInjection.shared.resolve(EmailVerificationViewModel.self)
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
            
            if case .error(let message) = emailVerificationViewModel.screenState {
                Text(message)
                    .foregroundStyle(Color.red)
            }
            
            Spacer()
            
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
