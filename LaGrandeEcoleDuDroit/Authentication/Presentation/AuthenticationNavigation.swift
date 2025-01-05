import SwiftUI

struct AuthenticationNavigation: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @StateObject private var navigationCoordinator = CommonDependencyInjectionContainer.shared.resolve(NavigationCoordinator.self)
    
    var body: some View {
        NavigationStack(path: $navigationCoordinator.path) {
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
                            .environmentObject(navigationCoordinator)
                        
                    case .secondRegistration:
                        SecondRegistrationView()
                            .environmentObject(registrationViewModel)
                            .environmentObject(navigationCoordinator)
                        
                    case .thirdRegistration:
                        ThirdRegistrationView()
                            .environmentObject(registrationViewModel)
                            .environmentObject(navigationCoordinator)
                        
                    case .emailVerification(let email):
                        let registrationViewModel = AuthenticationDependencyInjectionContainer.shared.resolve(RegistrationViewModel.self, arguments: email)!
                        EmailVerificationView()
                            .environmentObject(registrationViewModel)
                            .environmentObject(navigationCoordinator)
                    }
                }
        }
        .environmentObject(navigationCoordinator)
    }
}

#Preview {
    struct AuthenticationNavigation_Preview: View {
        @StateObject var navigationCoordinator = CommonDependencyInjectionContainer.shared.resolve(NavigationCoordinator.self)
        let tabBarVisibility = CommonDependencyInjectionContainer.shared.resolve(TabBarVisibility.self)
        let mockAuthenticationViewModel = AuthenticationDependencyInjectionContainer.shared.resolveWithMock().resolve(AuthenticationViewModel.self)!
        let mockRegistrationViewModel = AuthenticationDependencyInjectionContainer.shared.resolveWithMock().resolve(RegistrationViewModel.self)!
        
        var body: some View {
            NavigationStack(path: $navigationCoordinator.path) {
                AuthenticationNavigation()
                    .environmentObject(mockAuthenticationViewModel)
                    .environmentObject(mockRegistrationViewModel)
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
                            EmailVerificationView()
                        }
                    }
            }
            .environmentObject(mockAuthenticationViewModel)
            .environmentObject(mockRegistrationViewModel)
            .environmentObject(navigationCoordinator)
            .environmentObject(tabBarVisibility)
        }
    }
    
    return AuthenticationNavigation_Preview()
}
