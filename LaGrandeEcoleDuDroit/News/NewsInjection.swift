import Swinject

class NewsInjection: DependencyInjectionContainer {
    static var shared: DependencyInjectionContainer = NewsInjection()
    private let container: Container
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        container.register(AnnouncementApi.self) { _ in AnnouncementApiImpl() }
            .inObjectScope(.container)
        
        container.register(AnnouncementRemoteDataSource.self) { resolver in
            AnnouncementRemoteDataSource(announcementApi: resolver.resolve(AnnouncementApi.self)!)
        }.inObjectScope(.container)
        
        container.register(AnnouncementLocalDataSource.self) { resolver in
            AnnouncementLocalDataSource(gedDatabaseContainer: CommonInjection.shared.resolve(GedDatabaseContainer.self))
        }.inObjectScope(.container)
        
        container.register(AnnouncementRepository.self) { resolver in
            AnnouncementRepositoryImpl(
                announcementLocalDataSource: resolver.resolve(AnnouncementLocalDataSource.self)!,
                announcementRemoteDataSource: resolver.resolve(AnnouncementRemoteDataSource.self)!
            )
        }.inObjectScope(.container)
        
        container.register(GetAnnouncementsUseCase.self) { resolver in
            GetAnnouncementsUseCase(announcementRepository: resolver.resolve(AnnouncementRepository.self)!)
        }
        
        container.register(GetAnnouncementUseCase.self) { resolver in
            GetAnnouncementUseCase(announcementRepository: resolver.resolve(AnnouncementRepository.self)!)
        }
        
        container.register(CreateAnnouncementUseCase.self) { resolver in
            CreateAnnouncementUseCase(announcementRepository: resolver.resolve(AnnouncementRepository.self)!)
        }
        
        container.register(UpdateAnnouncementUseCase.self) { resolver in
            UpdateAnnouncementUseCase(announcementRepository: resolver.resolve(AnnouncementRepository.self)!)
        }
        
        container.register(DeleteAnnouncementUseCase.self) { resolver in
            DeleteAnnouncementUseCase(announcementRepository: resolver.resolve(AnnouncementRepository.self)!)
        }
        
        container.register(ResendErrorAnnouncementUseCase.self) { resolver in
            ResendErrorAnnouncementUseCase(announcementRepository: resolver.resolve(AnnouncementRepository.self)!)
        }
        
        container.register(NewsViewModel.self) { resolver in
            NewsViewModel(
                getCurrentUserUseCase: CommonInjection.shared.resolve(GetCurrentUserUseCase.self),
                getAnnouncementsUseCase: resolver.resolve(GetAnnouncementsUseCase.self)!,
                deleteAnnouncementUseCase: resolver.resolve(DeleteAnnouncementUseCase.self)!,
                resendErrorAnnouncementUseCase: resolver.resolve(ResendErrorAnnouncementUseCase.self)!
            )
        }.inObjectScope(.weak)
        
        container.register(ReadAnnouncementViewModel.self) { (resolver, announcement: Any) in
            let announcement = announcement as! Announcement
            return ReadAnnouncementViewModel(
                updateAnnouncementUseCase: resolver.resolve(UpdateAnnouncementUseCase.self)!,
                deleteAnnouncementUseCase: resolver.resolve(DeleteAnnouncementUseCase.self)!,
                getCurrentUserUseCase: CommonInjection.shared.resolve(GetCurrentUserUseCase.self),
                getAnnouncementUseCase: resolver.resolve(GetAnnouncementUseCase.self)!,
                announcement: announcement
            )
        }.inObjectScope(.weak)
        
        container.register(CreateAnnouncementViewModel.self) { resolver in
            CreateAnnouncementViewModel(
                createAnnouncementUseCase: resolver.resolve(CreateAnnouncementUseCase.self)!,
                generateIdUseCase: CommonInjection.shared.resolve(GenerateIdUseCase.self),
                getCurrentUserUseCase: CommonInjection.shared.resolve(GetCurrentUserUseCase.self)
            )
        }.inObjectScope(.weak)
        
        container.register(EditAnnouncementViewModel.self) { (resolver, announcement: Any) in
            let announcement = announcement as! Announcement
            return EditAnnouncementViewModel(
                updateAnnouncementUseCase: resolver.resolve(UpdateAnnouncementUseCase.self)!,
                announcement: announcement
            )
        }
        .inObjectScope(.weak)
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
        
        mockContainer.register(GetAnnouncementsUseCase.self) { resolver in
            GetAnnouncementsUseCase(announcementRepository: resolver.resolve(AnnouncementRepository.self)!)
        }
        
        mockContainer.register(GetAnnouncementUseCase.self) { resolver in
            GetAnnouncementUseCase(announcementRepository: resolver.resolve(AnnouncementRepository.self)!)
        }
        
        mockContainer.register(CreateAnnouncementUseCase.self) { resolver in
            CreateAnnouncementUseCase(announcementRepository: resolver.resolve(AnnouncementRepository.self)!)
        }
        
        mockContainer.register(UpdateAnnouncementUseCase.self) { resolver in
            UpdateAnnouncementUseCase(announcementRepository: resolver.resolve(AnnouncementRepository.self)!)
        }
        
        mockContainer.register(DeleteAnnouncementUseCase.self) { resolver in
            DeleteAnnouncementUseCase(announcementRepository: resolver.resolve(AnnouncementRepository.self)!)
        }
        
        mockContainer.register(ResendErrorAnnouncementUseCase.self) { resolver in
            ResendErrorAnnouncementUseCase(announcementRepository: resolver.resolve(AnnouncementRepository.self)!)
        }
        
        mockContainer.register(NewsViewModel.self) { resolver in
            NewsViewModel(
                getCurrentUserUseCase: commonMockContainer.resolve(GetCurrentUserUseCase.self)!,
                getAnnouncementsUseCase: resolver.resolve(GetAnnouncementsUseCase.self)!,
                deleteAnnouncementUseCase: resolver.resolve(DeleteAnnouncementUseCase.self)!,
                resendErrorAnnouncementUseCase: resolver.resolve(ResendErrorAnnouncementUseCase.self)!
            )
        }
        
        mockContainer.register(CreateAnnouncementViewModel.self) { resolver in
            CreateAnnouncementViewModel(
                createAnnouncementUseCase: resolver.resolve(CreateAnnouncementUseCase.self)!,
                generateIdUseCase: commonMockContainer.resolve(GenerateIdUseCase.self)!,
                getCurrentUserUseCase: commonMockContainer.resolve(GetCurrentUserUseCase.self)!
            )
        }
        
        mockContainer.register(ReadAnnouncementViewModel.self) { (resolver, announcement: Any) in
            let announcement = announcement as! Announcement
            return ReadAnnouncementViewModel(
                updateAnnouncementUseCase: resolver.resolve(UpdateAnnouncementUseCase.self)!,
                deleteAnnouncementUseCase: resolver.resolve(DeleteAnnouncementUseCase.self)!,
                getCurrentUserUseCase: commonMockContainer.resolve(GetCurrentUserUseCase.self)!,
                getAnnouncementUseCase: commonMockContainer.resolve(GetAnnouncementUseCase.self)!,
                announcement: announcement
            )
        }
        
        return mockContainer
    }
}
