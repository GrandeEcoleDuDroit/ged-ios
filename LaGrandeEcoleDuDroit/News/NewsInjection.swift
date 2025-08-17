import Swinject

class NewsInjection: DependencyInjectionContainer {
    static var shared: DependencyInjectionContainer = NewsInjection()
    private let container: Container
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        // Api
        container.register(AnnouncementApi.self) { _ in
            AnnouncementApiImpl(tokenProvider: MainInjection.shared.resolve(TokenProvider.self))
        }.inObjectScope(.container)
        
        // Data sources
        
        container.register(AnnouncementRemoteDataSource.self) { resolver in
            AnnouncementRemoteDataSource(announcementApi: resolver.resolve(AnnouncementApi.self)!)
        }.inObjectScope(.container)
        
        container.register(AnnouncementLocalDataSource.self) { resolver in
            AnnouncementLocalDataSource(gedDatabaseContainer: CommonInjection.shared.resolve(GedDatabaseContainer.self))
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
            CreateAnnouncementUseCase(announcementRepository: resolver.resolve(AnnouncementRepository.self)!)
        }.inObjectScope(.container)
        
        container.register(DeleteAnnouncementUseCase.self) { resolver in
            DeleteAnnouncementUseCase(
                announcementRepository: resolver.resolve(AnnouncementRepository.self)!,
                networkMonitor: CommonInjection.shared.resolve(NetworkMonitor.self)
            )
        }.inObjectScope(.container)
        
        container.register(ResendAnnouncementUseCase.self) { resolver in
            ResendAnnouncementUseCase(
                announcementRepository: resolver.resolve(AnnouncementRepository.self)!,
                networkMonitor: CommonInjection.shared.resolve(NetworkMonitor.self)
            )
        }.inObjectScope(.container)
        
        container.register(RefreshAnnouncementsUseCase.self) { resolver in
            RefreshAnnouncementsUseCase(
                announcementRepository: resolver.resolve(AnnouncementRepository.self)!,
                networkMonitor: CommonInjection.shared.resolve(NetworkMonitor.self)
            )
        }.inObjectScope(.container)
        
        // View models
        
        container.register(NewsViewModel.self) { resolver in
            NewsViewModel(
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
                announcementRepository: resolver.resolve(AnnouncementRepository.self)!,
                deleteAnnouncementUseCase: resolver.resolve(DeleteAnnouncementUseCase.self)!,
                resendAnnouncementUseCase: resolver.resolve(ResendAnnouncementUseCase.self)!,
                refreshAnnouncementsUseCase: resolver.resolve(RefreshAnnouncementsUseCase.self)!,
            )
        }
        
        container.register(ReadAnnouncementViewModel.self) { (resolver, announcementId: Any) in
            let announcementId = announcementId as! String
            return ReadAnnouncementViewModel(
                announcementId: announcementId,
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
                announcementRepository: resolver.resolve(AnnouncementRepository.self)!,
                deleteAnnouncementUseCase: resolver.resolve(DeleteAnnouncementUseCase.self)!
            )
        }
        
        container.register(CreateAnnouncementViewModel.self) { resolver in
            CreateAnnouncementViewModel(
                createAnnouncementUseCase: resolver.resolve(CreateAnnouncementUseCase.self)!,
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
            )
        }
        
        container.register(EditAnnouncementViewModel.self) { (resolver, announcement: Any) in
            let announcement = announcement as! Announcement
            return EditAnnouncementViewModel(
                announcement: announcement,
                announcementRepository: resolver.resolve(AnnouncementRepository.self)!
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
        let commonMockContainer = CommonInjection.shared.resolveWithMock()
        
        mockContainer.register(AnnouncementRepository.self) { _ in MockAnnouncementRepository() }
       
        mockContainer.register(CreateAnnouncementUseCase.self) { resolver in
            CreateAnnouncementUseCase(announcementRepository: resolver.resolve(AnnouncementRepository.self)!)
        }
        
        mockContainer.register(DeleteAnnouncementUseCase.self) { resolver in
            DeleteAnnouncementUseCase(
                announcementRepository: resolver.resolve(AnnouncementRepository.self)!,
                networkMonitor: commonMockContainer.resolve(NetworkMonitor.self)!
            )
        }
        
        mockContainer.register(ResendAnnouncementUseCase.self) { resolver in
            ResendAnnouncementUseCase(
                announcementRepository: resolver.resolve(AnnouncementRepository.self)!,
                networkMonitor: commonMockContainer.resolve(NetworkMonitor.self)!
            )
        }
        
        mockContainer.register(RefreshAnnouncementsUseCase.self) { resolver in
            RefreshAnnouncementsUseCase(
                announcementRepository: resolver.resolve(AnnouncementRepository.self)!,
                networkMonitor: commonMockContainer.resolve(NetworkMonitor.self)!
            )
        }
        
        mockContainer.register(NewsViewModel.self) { resolver in
            NewsViewModel(
                userRepository: commonMockContainer.resolve(UserRepository.self)!,
                announcementRepository: resolver.resolve(AnnouncementRepository.self)!,
                deleteAnnouncementUseCase: resolver.resolve(DeleteAnnouncementUseCase.self)!,
                resendAnnouncementUseCase: resolver.resolve(ResendAnnouncementUseCase.self)!,
                refreshAnnouncementsUseCase: resolver.resolve(RefreshAnnouncementsUseCase.self)!
            )
        }
        
        mockContainer.register(CreateAnnouncementViewModel.self) { resolver in
            CreateAnnouncementViewModel(
                createAnnouncementUseCase: resolver.resolve(CreateAnnouncementUseCase.self)!,
                userRepository: commonMockContainer.resolve(UserRepository.self)!,
            )
        }
        
        mockContainer.register(ReadAnnouncementViewModel.self) { (resolver, announcementId: Any) in
            let announcementId = announcementId as! String
            return ReadAnnouncementViewModel(
                announcementId: announcementId,
                userRepository: commonMockContainer.resolve(UserRepository.self)!,
                announcementRepository: resolver.resolve(AnnouncementRepository.self)!,
                deleteAnnouncementUseCase: resolver.resolve(DeleteAnnouncementUseCase.self)!
            )
        }
        
        return mockContainer
    }
}
