import Swinject

class CommonInjector: Injector {
    let container: Container
    static var shared: Injector = CommonInjector()
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        container.register(GedDatabaseContainer.self) { _ in
            GedDatabaseContainer()
        }.inObjectScope(.container)
        
        // Api
        container.register(UserServerApi.self) { resolver in
            UserServerApi(tokenProvider: AppInjector.shared.resolve(TokenProvider.self))
        }.inObjectScope(.container)
        
        container.register(UserFirestoreApi.self) { resolver in
            UserFirestoreApi()
        }.inObjectScope(.container)
        
        container.register(UserApi.self) { resolver in
            UserApiImpl(
                userFirestoreApi: resolver.resolve(UserFirestoreApi.self)!,
                userServerApi: resolver.resolve(UserServerApi.self)!
            )
        }.inObjectScope(.container)
        
        container.register(ImageApi.self) { _ in
            ImageApiImpl(tokenProvider: AppInjector.shared.resolve(TokenProvider.self))
        }.inObjectScope(.container)
        
        container.register(WhiteListApi.self) { _ in
            WhiteListApiImpl()
        }.inObjectScope(.container)
        
        container.register(FcmApi.self) { resolver in
            FcmApiImpl(tokenProvider: AppInjector.shared.resolve(TokenProvider.self))
        }.inObjectScope(.container)
        
        container.register(NotificationApi.self) { resolver in
            NotificationApiImpl(fcmApi: resolver.resolve(FcmApi.self)!)
        }.inObjectScope(.container)
        
        container.register(BlockedUserFirestoreApi.self) { _ in
            BlockedUserFirestoreApi()
        }.inObjectScope(.container)
        
        container.register(BlockedUserApi.self) { resolver in
            BlockedUserApiImpl(blockedUserFirestoreApi: resolver.resolve(BlockedUserFirestoreApi.self)!)
        }.inObjectScope(.container)
        
        // Data sources
        container.register(UserLocalDataSource.self) { _ in
            UserLocalDataSource()
        }.inObjectScope(.container)
        
        container.register(UserRemoteDataSource.self) { resolver in
            UserRemoteDataSource(
                userApi: resolver.resolve(UserApi.self)!
            )
        }.inObjectScope(.container)
        
        container.register(ImageLocalDataSource.self) { resolver in
            ImageLocalDataSource()
        }.inObjectScope(.container)
        
        container.register(ImageRemoteDataSource.self) { resolver in
            ImageRemoteDataSource(imageApi: resolver.resolve(ImageApi.self)!)
        }.inObjectScope(.container)
        
        container.register(FcmLocalDataSource.self) { _ in
            FcmLocalDataSource()
        }.inObjectScope(.container)
        
        container.register(BlockedUserLocalDataSource.self) { _ in
            BlockedUserLocalDataSource()
        }.inObjectScope(.container)
        
        container.register(BlockedUserRemoteDataSource.self) { resolver in
            BlockedUserRemoteDataSource(blockedUserApi: resolver.resolve(BlockedUserApi.self)!)
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
        
        container.register(BlockedUserRepository.self) { resolver in
            BlockedUserRepositoryImpl(
                blockedUserLocalDataSource: resolver.resolve(BlockedUserLocalDataSource.self)!,
                blockedUserRemoteDataSource: resolver.resolve(BlockedUserRemoteDataSource.self)!
            )
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
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                imageRepository: CommonInjector.shared.resolve(ImageRepository.self)
            )
        }.inObjectScope(.container)
        
        container.register(NavigationRequestUseCase.self) { resolver in
            NavigationRequestUseCase()
        }.inObjectScope(.container)
        
        container.register(FetchBlockedUsersUseCase.self) { resolver in
            FetchBlockedUsersUseCase(
                blockedUserRepository: resolver.resolve(BlockedUserRepository.self)!,
                userRepository: resolver.resolve(UserRepository.self)!
            )
        }
        
        container.register(GetUsersUseCase.self) { resolver in
            GetUsersUseCase(userRepository: resolver.resolve(UserRepository.self)!)
        }
        
        container.register(GetBlockedUsersUseCase.self) { resolver in
            GetBlockedUsersUseCase(
                blockedUserRepository: resolver.resolve(BlockedUserRepository.self)!,
                userRepository: resolver.resolve(UserRepository.self)!
            )
        }
        
        // Others
        container.register(NetworkMonitor.self) { _ in
            NetworkMonitorImpl()
        }.inObjectScope(.container)
    }
}
