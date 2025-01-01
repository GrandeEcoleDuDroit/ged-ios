import SwiftUI

struct AuthenticationNavigation: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @StateObject private var authenticationNavigationCoordinator = NavigationCoordinator()
    
    var body: some View {
        NavigationStack(path: $authenticationNavigationCoordinator.path) {
            AuthenticationView()
                .environmentObject(authenticationViewModel)
                .environmentObject(registrationViewModel)
                .navigationDestination(for: AuthenticationScreen.self) { screen in
                    switch screen {
                    case .forgottenPassword:
                        ForgottenPasswordView()
                        
                    case .firstRegistration:
                        FirstRegistrationView()
                            .environmentObject(registrationViewModel)
                            .environmentObject(authenticationNavigationCoordinator)
                        
                    case .secondRegistration:
                        SecondRegistrationView()
                            .environmentObject(registrationViewModel)
                            .environmentObject(authenticationNavigationCoordinator)
                        
                    case .thirdRegistration:
                        ThirdRegistrationView()
                            .environmentObject(registrationViewModel)
                            .environmentObject(authenticationNavigationCoordinator)
                        
                    case .emailVerification(let email):
                        let registrationViewModel = RegistrationViewModel(
                            email: email,
                            registerUseCase: DependencyContainer.shared.registerUseCase,
                            sendVerificationEmailUseCase: DependencyContainer.shared.sendVerificationEmailUseCase,
                            isEmailVerifiedUseCase: DependencyContainer.shared.isEmailVerifiedUseCase,
                            createUserUseCase: DependencyContainer.shared.createUserUseCase
                        )
                        EmailVerificationView()
                            .environmentObject(registrationViewModel)
                            .environmentObject(authenticationNavigationCoordinator)
                    }
                }
        }
        .environmentObject(authenticationNavigationCoordinator)
    }
}

#Preview {
    NavigationStack {
        AuthenticationNavigation()
            .environmentObject(DependencyContainer.shared.mockAuthenticationViewModel)
            .environmentObject(DependencyContainer.shared.mockRegistrationViewModel)
    }
}
