import Swinject

class NewsInjector: Injector {
    static var shared: Injector = NewsInjector()
    let container: Container
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        // Api
        container.register(AnnouncementApi.self) { _ in
            AnnouncementApiImpl(tokenProvider: AppInjector.shared.resolve(TokenProvider.self))
        }.inObjectScope(.container)
        
        // Data sources
        container.register(AnnouncementRemoteDataSource.self) { resolver in
            AnnouncementRemoteDataSource(announcementApi: resolver.resolve(AnnouncementApi.self)!)
        }.inObjectScope(.container)
        
        container.register(AnnouncementLocalDataSource.self) { resolver in
            AnnouncementLocalDataSource(gedDatabaseContainer: CommonInjector.shared.resolve(GedDatabaseContainer.self))
        }.inObjectScope(.container)
        
        // Repositories
        container.register(AnnouncementRepository.self) { resolver in
            AnnouncementRepositoryImpl(
                announcementLocalDataSource: resolver.resolve(AnnouncementLocalDataSource.self)!,
                announcementRemoteDataSource: resolver.resolve(AnnouncementRemoteDataSource.self)!
            )
        }.inObjectScope(.container)
        
        // Use cases
        container.register(CreateAnnouncementUseCase.self) { resolver in
            CreateAnnouncementUseCase(
                announcementRepository: resolver.resolve(AnnouncementRepository.self)!,
                announcementTaskReferences: resolver.resolve(AnnouncementTaskQueue.self)!
            )
        }.inObjectScope(.weak)
        
        container.register(DeleteAnnouncementUseCase.self) { resolver in
            DeleteAnnouncementUseCase(
                announcementRepository: resolver.resolve(AnnouncementRepository.self)!,
                announcementTaskReferences: resolver.resolve(AnnouncementTaskQueue.self)!
            )
        }.inObjectScope(.weak)
        
        container.register(RecreateAnnouncementUseCase.self) { resolver in
            RecreateAnnouncementUseCase(
                announcementRepository: resolver.resolve(AnnouncementRepository.self)!,
                announcementTaskReferences: resolver.resolve(AnnouncementTaskQueue.self)!
            )
        }.inObjectScope(.weak)
        
        container.register(RefreshAnnouncementsUseCase.self) { resolver in
            RefreshAnnouncementsUseCase(
                fetchAnnouncementsUseCase: resolver.resolve(FetchAnnouncementsUseCase.self)!
            )
        }.inObjectScope(.container)
        
        container.register(FetchAnnouncementsUseCase.self) { resolver in
            FetchAnnouncementsUseCase(
                announcementRepository: resolver.resolve(AnnouncementRepository.self)!,
                blockedUserRepository: CommonInjector.shared.resolve(BlockedUserRepository.self)
            )
        }.inObjectScope(.weak)
        
        // Others
        container.register(StartupAnnouncementTask.self) { resolver in
            StartupAnnouncementTask(
                networkMonitor: CommonInjector.shared.resolve(NetworkMonitor.self),
                announcementRepository: resolver.resolve(AnnouncementRepository.self)!,
                recreateAnnouncementUseCase: resolver.resolve(RecreateAnnouncementUseCase.self)!
            )
        }.inObjectScope(.weak)
        
        container.register(AnnouncementTaskQueue.self) { resolver in
            AnnouncementTaskQueue()
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
}
