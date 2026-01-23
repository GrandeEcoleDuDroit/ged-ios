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
        container.register(AuthenticationApi.self) { _ in
            AuthenticationApiImpl()
        }.inObjectScope(.container)
        
        // Data sources
        container.register(AuthenticationLocalDataSource.self) { _ in
            AuthenticationLocalDataSource()
        }.inObjectScope(.container)
        
        container.register(AuthenticationRemoteDataSource.self) { resolver in
            AuthenticationRemoteDataSource(
                authenticationApi: resolver.resolve(AuthenticationApi.self)!
            )
        }.inObjectScope(.container)
        
        // Repositories
        container.register(AuthenticationRepository.self) { resolver in
            AuthenticationRepositoryImpl(
                authenticationLocalDataSource: resolver.resolve(AuthenticationLocalDataSource.self)!,
                authenticationRemoteDataSource: resolver.resolve(AuthenticationRemoteDataSource.self)!
            )
        }.inObjectScope(.container)
        
        // Use cases
        container.register(LoginUseCase.self) { resolver in
            LoginUseCase(authenticationRepository: resolver.resolve(AuthenticationRepository.self)!)
        }.inObjectScope(.container)
    
        container.register(RegisterUseCase.self) { resolver in
            RegisterUseCase(
                authenticationRepository: resolver.resolve(AuthenticationRepository.self)!,
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                whiteListRepository: CommonInjector.shared.resolve(WhiteListRepository.self)
            )
        }
        
        container.register(LogoutUseCase.self) { resolver in
            LogoutUseCase(
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                authenticationRepository: resolver.resolve(AuthenticationRepository.self)!,
                fcmTokenRepository: CommonInjector.shared.resolve(FcmTokenRepository.self)
            )
        }
    }
}
