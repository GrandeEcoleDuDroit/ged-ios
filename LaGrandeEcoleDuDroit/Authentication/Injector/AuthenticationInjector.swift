import Swinject

class AuthenticationInjector: Injector {
    static var shared: Injector = AuthenticationInjector()
    let container: Container
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        // Api
        container.register(FirebaseAuthApi.self) { _ in
            FirebaseAuthApiImpl()
        }.inObjectScope(.container)
        
        // Data sources
        container.register(AuthenticationLocalDataSource.self) { _ in
            AuthenticationLocalDataSource()
        }.inObjectScope(.container)
        
        // Repositories
        container.register(FirebaseAuthenticationRepository.self) { resolver in
            FirebaseAuthenticationRepositoryImpl(firebaseAuthApi: resolver.resolve(FirebaseAuthApi.self)!)
        }.inObjectScope(.container)
        
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
                userRepository: CommonInjector.shared.resolve(UserRepository.self)
            )
        }.inObjectScope(.container)
    
        container.register(RegisterUseCase.self) { resolver in
            RegisterUseCase(
                authenticationRepository: resolver.resolve(AuthenticationRepository.self)!,
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                whiteListRepository: CommonInjector.shared.resolve(WhiteListRepository.self)
            )
        }
        
        container.register(ListenAuthenticationStateUseCase.self) { resolver in
            ListenAuthenticationStateUseCase(
                authenticationRepository: resolver.resolve(AuthenticationRepository.self)!,
                userRepository: CommonInjector.shared.resolve(UserRepository.self)
            )
        }.inObjectScope(.container)
    }
}
