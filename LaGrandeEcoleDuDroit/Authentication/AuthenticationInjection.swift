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
        
        container.register(LoginUseCase.self) { resolver in
            LoginUseCase(
                authenticationRepository: resolver.resolve(AuthenticationRepository.self)!,
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
                networkMonitor: CommonInjection.shared.resolve(NetworkMonitor.self)
            )
        }
    
        container.register(FirstRegistrationViewModel.self) { resolver in
            FirstRegistrationViewModel()
        }
        .inObjectScope(.weak)
        
        container.register(SecondRegistrationViewModel.self) { resolver in
            SecondRegistrationViewModel()
        }.inObjectScope(.weak)
        
        container.register(AuthenticationViewModel.self) { resolver in
            AuthenticationViewModel(
                loginUseCase: resolver.resolve(LoginUseCase.self)!
            )
        }.inObjectScope(.weak)
        
        container.register(FirstRegistrationViewModel.self) { resolver in
            FirstRegistrationViewModel()
        }.inObjectScope(.weak)
        
        container.register(ThirdRegistrationViewModel.self) { resolver in
            ThirdRegistrationViewModel(
                registerUseCase: resolver.resolve(RegisterUseCase.self)!
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
        
        mockContainer.register(AuthenticationRepository.self) { _ in MockAuthenticationRepository() }

        mockContainer.register(AuthenticationViewModel.self) { resolver in
            AuthenticationViewModel(
                loginUseCase: resolver.resolve(LoginUseCase.self)!
            )
        }
        
        mockContainer.register(ThirdRegistrationViewModel.self) { resolver in
            ThirdRegistrationViewModel(
                registerUseCase: resolver.resolve(RegisterUseCase.self)!
            )
        }
        
        return mockContainer
    }
}
