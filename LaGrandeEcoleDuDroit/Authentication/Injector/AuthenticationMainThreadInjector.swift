import Swinject

class AuthenticationMainThreadInjector: MainThreadInjector {
    let container: Container
    static var shared: MainThreadInjector = AuthenticationMainThreadInjector()
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        // View models
        container.register(AuthenticationViewModel.self) { resolver in
            AuthenticationViewModel(
                loginUseCase: AuthenticationInjector.shared.resolve(LoginUseCase.self)
            )
        }
        
        container.register(FirstRegistrationViewModel.self) { resolver in
            FirstRegistrationViewModel()
        }
        
        container.register(SecondRegistrationViewModel.self) { resolver in
            SecondRegistrationViewModel()
        }
        
        
        container.register(ThirdRegistrationViewModel.self) { resolver in
            ThirdRegistrationViewModel(
                registerUseCase:  AuthenticationInjector.shared.resolve(RegisterUseCase.self)
            )
        }
    }
}
