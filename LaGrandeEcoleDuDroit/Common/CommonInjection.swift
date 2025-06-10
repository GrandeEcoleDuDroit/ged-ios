import Swinject

class CommonInjection: DependencyInjectionContainer {
    static var shared: DependencyInjectionContainer = CommonInjection()
    private let container: Container
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {        
        container.register(UserFirestoreApi.self) { _ in
            UserFirestoreApiImpl()
        }.inObjectScope(.container)
        
        container.register(UserOracleApi.self) { _ in
            UserOracleApiImpl()
        }.inObjectScope(.container)
        
        container.register(ImageApi.self) { _ in
            ImageApiImpl()
        }.inObjectScope(.container)
        
        container.register(UserLocalDataSource.self) { _ in
            UserLocalDataSource()
        }.inObjectScope(.container)
        
        container.register(UserRemoteDataSource.self) { resolver in
            UserRemoteDataSource(
                userFirestoreApi: resolver.resolve(UserFirestoreApi.self)!,
                userOracleApi: resolver.resolve(UserOracleApi.self)!
            )
        }.inObjectScope(.container)
        
        container.register(NetworkMonitor.self) { _ in
            NetworkMonitorImpl()
        }.inObjectScope(.container)
        
        container.register(ImageRemoteDataSource.self) { resolver in
            ImageRemoteDataSource(imageApi: resolver.resolve(ImageApi.self)!)
        }.inObjectScope(.container)
        
        container.register(GedDatabaseContainer.self) { _ in
            GedDatabaseContainer()
        }.inObjectScope(.container)
        
        container.register(UserRepository.self) { resolver in
            UserRepositoryImpl(
                userLocalDataSource: resolver.resolve(UserLocalDataSource.self)!,
                userRemoteDataSource: resolver.resolve(UserRemoteDataSource.self)!
            )
        }.inObjectScope(.container)
        
        container.register(ImageRepository.self) { resolver in
            ImageRepositoryImpl(imageRemoteDataSource: resolver.resolve(ImageRemoteDataSource.self)!)
        }.inObjectScope(.container)
        
        container.register(GenerateIdUseCase.self) { _ in
            GenerateIdUseCase()
        }.inObjectScope(.container)
        
        container.register(UpdateProfilePictureUseCase.self) { resolver in
            UpdateProfilePictureUseCase(
                userRepository: resolver.resolve(UserRepository.self)!,
                imageRepository: resolver.resolve(ImageRepository.self)!
            )
        }.inObjectScope(.container)
        
        container.register(DeleteProfilePictureUseCase.self) { resolver in
            DeleteProfilePictureUseCase(
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
                imageRepository: CommonInjection.shared.resolve(ImageRepository.self)
            )
        }.inObjectScope(.container)
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
        
        mockContainer.register(ImageRepository.self) { _ in MockImageRepository() }
        
        mockContainer.register(GenerateIdUseCase.self) { _ in GenerateIdUseCase() }
        
        mockContainer.register(UpdateProfilePictureUseCase.self) { resolver in
            UpdateProfilePictureUseCase(
                userRepository: resolver.resolve(UserRepository.self)!,
                imageRepository: resolver.resolve(ImageRepository.self)!
            )
        }
        
        return mockContainer
    }
}
