import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @State private var isValid = false
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            Text(getString(.emailVerificationExplanationBegining))
                .font(.title3)
            
             + Text(registrationViewModel.email)
                .fontWeight(.semibold)
                .font(.title3)
                
             + Text(getString(.emailVerificationExplanationEnd))
                .font(.title3)
            
            if case .error(let message) = registrationViewModel.registrationState {
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
                    registrationViewModel.checkVerifiedEmail()
                }
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.gedPrimary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .onAppear {
            registrationViewModel.sendVerificationEmail()
        }
        .navigationTitle(getString(.emailVerificationTitle))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
    }
}

#Preview {
    let registrationViewModel = RegistrationViewModel(
        email: "email@example.com",
        registerUseCase: RegisterUseCase(
            authenticationRemoteRepository: DependencyContainer.shared.mockAuthenticationRepository
        ),
        sendVerificationEmailUseCase: SendVerificationEmailUseCase(
            authenticationRemoteRepository: DependencyContainer.shared.mockAuthenticationRepository
        ),
        isEmailVerifiedUseCase: IsEmailVerifiedUseCase(
            authenticationRemoteRepository: DependencyContainer.shared.mockAuthenticationRepository
        ),
        createUserUseCase: CreateUserUseCase(
            userRepository: DependencyContainer.shared.mockUserRepository
        )
    )
    
    NavigationStack {
        EmailVerificationView()
            .environmentObject(registrationViewModel)
    }
}
