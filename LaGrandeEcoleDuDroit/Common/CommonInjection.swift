import Swinject

class CommonInjection: DependencyInjectionContainer {
    static var shared: DependencyInjectionContainer = CommonInjection()
    private let container: Container
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {        
        container.register(UserFirestoreApi.self) { _ in UserFirestoreApiImpl() }
            .inObjectScope(.container)
        
        container.register(UserOracleApi.self) { _ in UserOracleApiImpl() }
            .inObjectScope(.container)
        
        container.register(UserLocalDataSource.self) { _ in UserLocalDataSource() }
            .inObjectScope(.container)
        
        container.register(UserRemoteDataSource.self) { resolver in
            UserRemoteDataSource(
                userFirestoreApi: resolver.resolve(UserFirestoreApi.self)!,
                userOracleApi: resolver.resolve(UserOracleApi.self)!
            )
        }
        .inObjectScope(.container)
        
        container.register(GedDatabaseContainer.self) { _ in GedDatabaseContainer() }
            .inObjectScope(.container)
        
        container.register(UserRepository.self) { resolver in
            UserRepositoryImpl(
                userLocalDataSource: resolver.resolve(UserLocalDataSource.self)!,
                userRemoteDataSource: resolver.resolve(UserRemoteDataSource.self)!
            )
        }
        .inObjectScope(.container)
        
        container.register(GenerateIdUseCase.self) { _ in GenerateIdUseCase() }
        
        container.register(CreateUserUseCase.self) { resolver in
            CreateUserUseCase(userRepository: resolver.resolve(UserRepository.self)!)
        }
        
        container.register(GetCurrentUserUseCase.self) { resolver in
            GetCurrentUserUseCase(userRepository: resolver.resolve(UserRepository.self)!)
        }
        
        container.register(SetCurrentUserUseCase.self) { resolver in
            SetCurrentUserUseCase(userRepository: resolver.resolve(UserRepository.self)!)
        }
        
        container.register(GetUserUseCase.self) { resolver in
            GetUserUseCase(userRepository: resolver.resolve(UserRepository.self)!)
        }
        
        container.register(GetUsersUseCase.self) { resolver in
            GetUsersUseCase(userRepository: resolver.resolve(UserRepository.self)!)
        }
        
        container.register(GetFilteredUsersUseCase.self) { resolver in
            GetFilteredUsersUseCase(userRepository: resolver.resolve(UserRepository.self)!)
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
        
        mockContainer.register(UserRepository.self) { _ in MockUserRepository() }
        
        mockContainer.register(GenerateIdUseCase.self) { _ in GenerateIdUseCase() }
        mockContainer.register(CreateUserUseCase.self) { resolver in
            CreateUserUseCase(userRepository: resolver.resolve(UserRepository.self)!)
        }
        mockContainer.register(GetCurrentUserUseCase.self) { resolver in
            GetCurrentUserUseCase(userRepository: resolver.resolve(UserRepository.self)!)
        }
        mockContainer.register(SetCurrentUserUseCase.self) { resolver in
            SetCurrentUserUseCase(userRepository: resolver.resolve(UserRepository.self)!)
        }
        mockContainer.register(GetUserUseCase.self) { resolver in
            GetUserUseCase(userRepository: resolver.resolve(UserRepository.self)!)
        }
        mockContainer.register(GetUsersUseCase.self) { resolver in
            GetUsersUseCase(userRepository: resolver.resolve(UserRepository.self)!)
        }
        mockContainer.register(GetFilteredUsersUseCase.self) { resolver in
            GetFilteredUsersUseCase(userRepository: resolver.resolve(UserRepository.self)!)
        }
        
        return mockContainer
    }
}
