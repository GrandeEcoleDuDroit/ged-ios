import Swinject

class AuthenticationDependencyInjectionContainer: DependencyInjectionContainer {
    static var shared: DependencyInjectionContainer = AuthenticationDependencyInjectionContainer()
    private let container: Container
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        container.register(FirebaseAuthApi.self) { _ in FirebaseAuthApiImpl() }
            .inObjectScope(.container)
        container.register(AuthenticationRepository.self) { resolver in
            AuthenticationRepositoryImpl(firebaseAuthApi: resolver.resolve(FirebaseAuthApi.self)!)
        }
        .inObjectScope(.container)
        
        container.register(SendVerificationEmailUseCase.self) { resolver in
            SendVerificationEmailUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
        }
        container.register(IsEmailVerifiedUseCase.self) { resolver in
            IsEmailVerifiedUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
        }
        container.register(IsAuthenticatedUseCase.self) { resolver in
            IsAuthenticatedUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
        }
        container.register(LoginUseCase.self) { resolver in
            LoginUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
        }
        container.register(LogoutUseCase.self) { resolver in
            LogoutUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
        }
        container.register(RegisterUseCase.self) { resolver in
            RegisterUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
        }
        
        container.register(AuthenticationViewModel.self) { resolver in
            AuthenticationViewModel(
                loginUseCase: resolver.resolve(LoginUseCase.self)!,
                isEmailVerifiedUseCase: resolver.resolve(IsEmailVerifiedUseCase.self)!,
                isAuthenticatedUseCase: resolver.resolve(IsAuthenticatedUseCase.self)!,
                getUserUseCase: CommonDependencyInjectionContainer.shared.resolve(GetUserUseCase.self),
                setCurrentUserUseCase: CommonDependencyInjectionContainer.shared.resolve(SetCurrentUserUseCase.self)
            )
        }
        container.register(RegistrationViewModel.self) { (resolver, email: String) in
            RegistrationViewModel(
                email: email,
                registerUseCase: resolver.resolve(RegisterUseCase.self)!,
                sendVerificationEmailUseCase: resolver.resolve(SendVerificationEmailUseCase.self)!,
                isEmailVerifiedUseCase: resolver.resolve(IsEmailVerifiedUseCase.self)!,
                createUserUseCase: CommonDependencyInjectionContainer.shared.resolve(CreateUserUseCase.self)
            )
        }
        container.register(RegistrationViewModel.self) { resolver in
            RegistrationViewModel(
                registerUseCase: resolver.resolve(RegisterUseCase.self)!,
                sendVerificationEmailUseCase: resolver.resolve(SendVerificationEmailUseCase.self)!,
                isEmailVerifiedUseCase: resolver.resolve(IsEmailVerifiedUseCase.self)!,
                createUserUseCase: CommonDependencyInjectionContainer.shared.resolve(CreateUserUseCase.self)
            )
        }
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        guard let resolved = container.resolve(T.self) else {
            fatalError("Failed to resolve \(T.self)")
        }
        return resolved
    }
    
    func resolve<T>(_ type: T.Type, arguments: Any...) -> T? {
        switch arguments.count {
        case 1:
            return container.resolve(T.self, argument: arguments[0])
        case 2:
            return container.resolve(T.self, arguments: arguments[0], arguments[1])
        case 3:
            return container.resolve(T.self, arguments: arguments[0], arguments[1], arguments[2])
        case 4:
            return container.resolve(T.self, arguments: arguments[0], arguments[1], arguments[2], arguments[3])
        case 5:
            return container.resolve(T.self, arguments: arguments[0], arguments[1], arguments[2], arguments[3], arguments[4])
        case 6:
            return container.resolve(T.self, arguments: arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5])
        case 7:
            return container.resolve(T.self, arguments: arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6])
        case 8:
            return container.resolve(T.self, arguments: arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6], arguments[7])
        case 9:
            return container.resolve(T.self, arguments: arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6], arguments[7], arguments[8])
        default:
            return nil
        }
    }
    
    func resolveWithMock() -> Container {
        let mockContainer = Container()
        let commonMockContainer = CommonDependencyInjectionContainer.shared.resolveWithMock()
        
        mockContainer.register(AuthenticationRepository.self) { _ in MockAuthenticationRepository() }
        
        mockContainer.register(SendVerificationEmailUseCase.self) { resolver in
            SendVerificationEmailUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
        }
        mockContainer.register(IsEmailVerifiedUseCase.self) { resolver in
            IsEmailVerifiedUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
        }
        mockContainer.register(IsAuthenticatedUseCase.self) { resolver in
            IsAuthenticatedUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
        }
        mockContainer.register(LoginUseCase.self) { resolver in
            LoginUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
        }
        mockContainer.register(LogoutUseCase.self) { resolver in
            LogoutUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
        }
        mockContainer.register(RegisterUseCase.self) { resolver in
            RegisterUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
        }
        
        mockContainer.register(AuthenticationViewModel.self) { resolver in
            AuthenticationViewModel(
                loginUseCase: resolver.resolve(LoginUseCase.self)!,
                isEmailVerifiedUseCase: resolver.resolve(IsEmailVerifiedUseCase.self)!,
                isAuthenticatedUseCase: resolver.resolve(IsAuthenticatedUseCase.self)!,
                getUserUseCase: commonMockContainer.resolve(GetUserUseCase.self)!,
                setCurrentUserUseCase: commonMockContainer.resolve(SetCurrentUserUseCase.self)!
            )
        }
        mockContainer.register(RegistrationViewModel.self) { resolver in
            RegistrationViewModel(
                registerUseCase: resolver.resolve(RegisterUseCase.self)!,
                sendVerificationEmailUseCase: resolver.resolve(SendVerificationEmailUseCase.self)!,
                isEmailVerifiedUseCase: resolver.resolve(IsEmailVerifiedUseCase.self)!,
                createUserUseCase: commonMockContainer.resolve(CreateUserUseCase.self)!
            )
        }
        mockContainer.register(RegistrationViewModel.self) { (resolver, email: String) in
            RegistrationViewModel(
                email: email,
                registerUseCase: resolver.resolve(RegisterUseCase.self)!,
                sendVerificationEmailUseCase: resolver.resolve(SendVerificationEmailUseCase.self)!,
                isEmailVerifiedUseCase: resolver.resolve(IsEmailVerifiedUseCase.self)!,
                createUserUseCase: commonMockContainer.resolve(CreateUserUseCase.self)!
            )
        }
        
        return mockContainer
    }
}
