import Swinject

class CommonInjection: DependencyInjectionContainer {
    static var shared: DependencyInjectionContainer = CommonInjection()
    private let container: Container
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        container.register(GedDatabaseContainer.self) { _ in
            GedDatabaseContainer()
        }.inObjectScope(.container)
        
        // Api
        
        container.register(UserFirestoreApi.self) { _ in
            UserFirestoreApiImpl()
        }.inObjectScope(.container)
        
        container.register(UserOracleApi.self) { _ in
            UserOracleApiImpl(tokenProvider: MainInjection.shared.resolve(TokenProvider.self))
        }.inObjectScope(.container)
        
        container.register(ImageApi.self) { _ in
            ImageApiImpl(tokenProvider: MainInjection.shared.resolve(TokenProvider.self))
        }.inObjectScope(.container)
        
        container.register(WhiteListApi.self) { _ in
            WhiteListApiImpl(tokenProvider: MainInjection.shared.resolve(TokenProvider.self))
        }.inObjectScope(.container)
        
        container.register(FcmApi.self) { resolver in
            FcmApiImpl(tokenProvider: MainInjection.shared.resolve(TokenProvider.self))
        }.inObjectScope(.container)
        
        container.register(NotificationApi.self) { resolver in
            NotificationApiImpl(fcmApi: resolver.resolve(FcmApi.self)!)
        }.inObjectScope(.container)
        
        // Data sources
        
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
        
        container.register(ImageLocalDataSource.self) { resolver in
            ImageLocalDataSource()
        }.inObjectScope(.container)
        
        container.register(FcmLocalDataSource.self) { _ in
            FcmLocalDataSource()
        }.inObjectScope(.container)
                
        // Repositories
        
        container.register(UserRepository.self) { resolver in
            UserRepositoryImpl(
                userLocalDataSource: resolver.resolve(UserLocalDataSource.self)!,
                userRemoteDataSource: resolver.resolve(UserRemoteDataSource.self)!
            )
        }.inObjectScope(.container)
        
        container.register(ImageRepository.self) { resolver in
            ImageRepositoryImpl(
                imageLocalDataSource: resolver.resolve(ImageLocalDataSource.self)!,
                imageRemoteDataSource: resolver.resolve(ImageRemoteDataSource.self)!
            )
        }.inObjectScope(.container)
        
        container.register(WhiteListRepository.self) { resolver in
            WhiteListRepositoryImpl(
                whiteListApi: resolver.resolve(WhiteListApi.self)!
            )
        }.inObjectScope(.container)
        
        container.register(FcmTokenRepository.self) { resolver in
            FcmTokenRepositoryImpl(
                fcmLocalDataSource: resolver.resolve(FcmLocalDataSource.self)!,
                fcmApi: resolver.resolve(FcmApi.self)!,
            )
        }
        
        container.register(RouteRepository.self) { resolver in
            RouteRepositoryImpl()
        }.inObjectScope(.container)
        
        // Use cases
        
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
        
        container.register(NavigationRequestUseCase.self) { resolver in
            NavigationRequestUseCase()
        }.inObjectScope(.container)
        
        container.register(LoadImageUseCase.self) { resolver in
            LoadImageUseCase(imageRepository: resolver.resolve(ImageRepository.self)!)
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
        
        mockContainer.register(ImageRepository.self) { _ in MockImageRepository() }
        
        mockContainer.register(GenerateIdUseCase.self) { _ in GenerateIdUseCase() }
        
        mockContainer.register(UpdateProfilePictureUseCase.self) { resolver in
            UpdateProfilePictureUseCase(
                userRepository: resolver.resolve(UserRepository.self)!,
                imageRepository: resolver.resolve(ImageRepository.self)!
            )
        }
        
        mockContainer.register(LoadImageUseCase.self) { resolver in
            LoadImageUseCase(imageRepository: resolver.resolve(ImageRepository.self)!)
        }
        
        return mockContainer
    }
}
