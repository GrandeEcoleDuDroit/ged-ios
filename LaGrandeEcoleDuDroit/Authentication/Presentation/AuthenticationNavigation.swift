import SwiftUI

struct AuthenticationNavigation: View {
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    
    var body: some View {
        NavigationStack(path: $navigationCoordinator.path) {
            AuthenticationView()
                .navigationDestination(for: AuthenticationScreen.self) { screen in
                    switch screen {
                    case .forgottenPassword:
                        ForgottenPasswordView()
                        
                    case .firstRegistration:
                        FirstRegistrationView()
                        
                    case .secondRegistration:
                        SecondRegistrationView()
                        
                    case .thirdRegistration:
                        ThirdRegistrationView()
                        
                    case .emailVerification(let email):
                        EmailVerificationView(email: email)
                    }
                }
        }
        .environmentObject(navigationCoordinator)
    }
}

#Preview {
    struct AuthenticationNavigation_Preview: View {
        @StateObject var navigationCoordinator = NavigationCoordinator()
        
        var body: some View {
            NavigationStack(path: $navigationCoordinator.path) {
                AuthenticationNavigation()
                    .navigationDestination(for: AuthenticationScreen.self) { screen in
                        switch screen {
                        case .forgottenPassword:
                            ForgottenPasswordView()
                            
                        case .firstRegistration:
                            FirstRegistrationView()
                            
                        case .secondRegistration:
                            SecondRegistrationView()
                            
                        case .thirdRegistration:
                            ThirdRegistrationView()
                            
                        case .emailVerification:
                            EmailVerificationView(email: "example@email.com")
                        }
                    }
            }
            .environmentObject(navigationCoordinator)
        }
    }
    
    return AuthenticationNavigation_Preview()
}
