import Swinject

class AuthenticationInjection: DependencyInjectionContainer {
    static var shared: DependencyInjectionContainer = AuthenticationInjection()
    private let container: Container
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        container.register(FirebaseAuthApi.self) { _ in FirebaseAuthApiImpl() }
            .inObjectScope(.container)
        
        container.register(FirebaseAuthenticationRepository.self) { resolver in
            FirebaseAuthenticationRepositoryImpl(firebaseAuthApi: resolver.resolve(FirebaseAuthApi.self)!)
        }.inObjectScope(.container)
        
        container.register(AuthenticationLocalDataSource.self) { _ in
            AuthenticationLocalDataSource()
        }.inObjectScope(.container)
        
        container.register(AuthenticationRepository.self) { resolver in
            AuthenticationRepositoryImpl(
                firebaseAuthenticationRepository: resolver.resolve(FirebaseAuthenticationRepository.self)!,
                authenticationLocalDataSource: resolver.resolve(AuthenticationLocalDataSource.self)!
            )
        }.inObjectScope(.container)
        
        container.register(SendVerificationEmailUseCase.self) { resolver in
            SendVerificationEmailUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
        }
        
        container.register(IsEmailVerifiedUseCase.self) { resolver in
            IsEmailVerifiedUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
        }
        
        container.register(IsUserAuthenticatedUseCase.self) { resolver in
            IsUserAuthenticatedUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
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
        
        container.register(SetUserAuthenticatedUseCase.self) { resolver in
            SetUserAuthenticatedUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
        }
        
        container.register(AuthenticationViewModel.self) { resolver in
            AuthenticationViewModel(
                loginUseCase: resolver.resolve(LoginUseCase.self)!,
                isEmailVerifiedUseCase: resolver.resolve(IsEmailVerifiedUseCase.self)!,
                isAuthenticatedUseCase: resolver.resolve(IsUserAuthenticatedUseCase.self)!,
                getUserUseCase: CommonInjection.shared.resolve(GetUserUseCase.self),
                setCurrentUserUseCase: CommonInjection.shared.resolve(SetCurrentUserUseCase.self),
                setUserAuthenticatedUseCase: resolver.resolve(SetUserAuthenticatedUseCase.self)!
            )
        }.inObjectScope(.weak)
        
        container.register(RegistrationViewModel.self) { resolver in
            RegistrationViewModel(
                registerUseCase: resolver.resolve(RegisterUseCase.self)!,
                createUserUseCase: CommonInjection.shared.resolve(CreateUserUseCase.self)
            )
        }.inObjectScope(.weak)
        
        container.register(EmailVerificationViewModel.self) { resolver in
            EmailVerificationViewModel(
                sendVerificationEmailUseCase: resolver.resolve(SendVerificationEmailUseCase.self)!,
                isEmailVerifiedUseCase: resolver.resolve(IsEmailVerifiedUseCase.self)!
            )
        }.inObjectScope(.weak)
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
        let commonMockContainer = CommonInjection.shared.resolveWithMock()
        
        mockContainer.register(AuthenticationRepository.self) { _ in MockAuthenticationRepository() }
        
        mockContainer.register(SendVerificationEmailUseCase.self) { resolver in
            SendVerificationEmailUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
        }
        mockContainer.register(IsEmailVerifiedUseCase.self) { resolver in
            IsEmailVerifiedUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
        }
        mockContainer.register(IsUserAuthenticatedUseCase.self) { resolver in
            IsUserAuthenticatedUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
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
        
        mockContainer.register(SetUserAuthenticatedUseCase.self) { resolver in
            SetUserAuthenticatedUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
        }
        
        mockContainer.register(AuthenticationViewModel.self) { resolver in
            AuthenticationViewModel(
                loginUseCase: resolver.resolve(LoginUseCase.self)!,
                isEmailVerifiedUseCase: resolver.resolve(IsEmailVerifiedUseCase.self)!,
                isAuthenticatedUseCase: resolver.resolve(IsUserAuthenticatedUseCase.self)!,
                getUserUseCase: commonMockContainer.resolve(GetUserUseCase.self)!,
                setCurrentUserUseCase: commonMockContainer.resolve(SetCurrentUserUseCase.self)!,
                setUserAuthenticatedUseCase: commonMockContainer.resolve(SetUserAuthenticatedUseCase.self)!
            )
        }
        
        mockContainer.register(RegistrationViewModel.self) { resolver in
            RegistrationViewModel(
                registerUseCase: resolver.resolve(RegisterUseCase.self)!,
                createUserUseCase: commonMockContainer.resolve(CreateUserUseCase.self)!
            )
        }
        
        mockContainer.register(EmailVerificationViewModel.self) { resolver in
            EmailVerificationViewModel(
                sendVerificationEmailUseCase: resolver.resolve(SendVerificationEmailUseCase.self)!,
                isEmailVerifiedUseCase: resolver.resolve(IsEmailVerifiedUseCase.self)!
            )
        }
        
        return mockContainer
    }
}
