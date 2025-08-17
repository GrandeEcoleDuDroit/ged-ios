import Swinject

class AuthenticationInjection: DependencyInjectionContainer {
    static var shared: DependencyInjectionContainer = AuthenticationInjection()
    private let container: Container
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        // Api
        container.register(FirebaseAuthApi.self) { _ in
            FirebaseAuthApiImpl()
        }.inObjectScope(.container)
        
        // Repositories
        
        container.register(FirebaseAuthenticationRepository.self) { resolver in
            FirebaseAuthenticationRepositoryImpl(firebaseAuthApi: resolver.resolve(FirebaseAuthApi.self)!)
        }.inObjectScope(.container)
        
        // Data sources
        
        container.register(AuthenticationLocalDataSource.self) { _ in
            AuthenticationLocalDataSource()
        }.inObjectScope(.container)
        
        // Repositories
        
        container.register(AuthenticationRepository.self) { resolver in
            AuthenticationRepositoryImpl(
                firebaseAuthenticationRepository: resolver.resolve(FirebaseAuthenticationRepository.self)!,
                authenticationLocalDataSource: resolver.resolve(AuthenticationLocalDataSource.self)!
            )
        }.inObjectScope(.container)
        
        // Use cases
        
        container.register(LoginUseCase.self) { resolver in
            LoginUseCase(
                authenticationRepository: resolver.resolve(AuthenticationRepository.self)!,
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
                networkMonitor: CommonInjection.shared.resolve(NetworkMonitor.self)
            )
        }.inObjectScope(.container)
    
        container.register(RegisterUseCase.self) { resolver in
            RegisterUseCase(
                authenticationRepository: resolver.resolve(AuthenticationRepository.self)!,
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
                whiteListRepository: CommonInjection.shared.resolve(WhiteListRepository.self),
                networkMonitor: CommonInjection.shared.resolve(NetworkMonitor.self)
            )
        }
        
        // View models
        
        container.register(FirstRegistrationViewModel.self) { resolver in
            FirstRegistrationViewModel()
        }
        
        container.register(SecondRegistrationViewModel.self) { resolver in
            SecondRegistrationViewModel()
        }
        
        container.register(AuthenticationViewModel.self) { resolver in
            AuthenticationViewModel(
                loginUseCase: resolver.resolve(LoginUseCase.self)!
            )
        }
        
        container.register(FirstRegistrationViewModel.self) { resolver in
            FirstRegistrationViewModel()
        }
        
        container.register(ThirdRegistrationViewModel.self) { resolver in
            ThirdRegistrationViewModel(
                registerUseCase: resolver.resolve(RegisterUseCase.self)!
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
