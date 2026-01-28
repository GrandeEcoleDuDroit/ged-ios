import Swinject

class MissionInjector: Injector {
    static var shared: Injector = MissionInjector()
    let container: Container
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        // Api
        container.register(MissionApi.self) { _ in
            MissionApiImpl(tokenProvider: AppInjector.shared.resolve(TokenProvider.self))
        }.inObjectScope(.container)
        
        // Data sources
        container.register(MissionRemoteDataSource.self) { resolver in
            MissionRemoteDataSource(missionApi: resolver.resolve(MissionApi.self)!)
        }.inObjectScope(.container)
        
        container.register(MissionLocalDataSource.self) { resolver in
            MissionLocalDataSource(gedDatabaseContainer: CommonInjector.shared.resolve(GedDatabaseContainer.self))
        }.inObjectScope(.container)
        
        // Repositories
        container.register(MissionRepository.self) { resolver in
            MissionRepositoryImpl(
                missionLocalDataSource: resolver.resolve(MissionLocalDataSource.self)!,
                missionRemoteDataSource: resolver.resolve(MissionRemoteDataSource.self)!
            )
        }.inObjectScope(.container)
        
        // Use cases
        container.register(CreateMissionUseCase.self) { resolver in
            CreateMissionUseCase(
                missionRepository: resolver.resolve(MissionRepository.self)!,
                imageRepository: CommonInjector.shared.resolve(ImageRepository.self),
                missionTaskQueue: resolver.resolve(MissionTaskQueue.self)!
            )
        }
        
        container.register(DeleteMissionUseCase.self) { resolver in
            DeleteMissionUseCase(
                missionRepository: resolver.resolve(MissionRepository.self)!,
                imageRepository: CommonInjector.shared.resolve(ImageRepository.self),
                missionTaskQueue: resolver.resolve(MissionTaskQueue.self)!
            )
        }
        
        container.register(FetchMissionsUseCase.self) { resolver in
            FetchMissionsUseCase(
                missionRepository: resolver.resolve(MissionRepository.self)!,
                upsertMissionUseCase: resolver.resolve(UpsertMissionUseCase.self)!
            )
        }
        
        container.register(RefreshMissionsUseCase.self) { resolver in
            RefreshMissionsUseCase(fetchMissionsUseCase: resolver.resolve(FetchMissionsUseCase.self)!)
        }.inObjectScope(.container)
        
        container.register(UpdateMissionUseCase.self) { resolver in
            UpdateMissionUseCase(
                missionRepository: resolver.resolve(MissionRepository.self)!,
                imageRepository: CommonInjector.shared.resolve(ImageRepository.self)
            )
        }
        
        container.register(RecreateMissionUseCase.self) { resolver in
            RecreateMissionUseCase(
                missionRepository: resolver.resolve(MissionRepository.self)!,
                imageRepository: CommonInjector.shared.resolve(ImageRepository.self),
                missionTaskQueue: resolver.resolve(MissionTaskQueue.self)!
            )
        }
        
        container.register(UpsertMissionUseCase.self) { resolver in
            UpsertMissionUseCase(
                missionRepository: resolver.resolve(MissionRepository.self)!,
                imageRepository: CommonInjector.shared.resolve(ImageRepository.self)
            )
        }.inObjectScope(.weak)
        
        container.register(DeleteMissionUseCase.self) { resolver in
            DeleteMissionUseCase(
                missionRepository: resolver.resolve(MissionRepository.self)!,
                imageRepository: CommonInjector.shared.resolve(ImageRepository.self),
                missionTaskQueue: resolver.resolve(MissionTaskQueue.self)!
            )
        }
        
        // Others
        container.register(StartupMissionTask.self) { resolver in
            StartupMissionTask(
                networkMonitor: CommonInjector.shared.resolve(NetworkMonitor.self),
                missionRepository: resolver.resolve(MissionRepository.self)!,
                recreateMissionUseCase: resolver.resolve(RecreateMissionUseCase.self)!
            )
        }
        
        container.register(MissionTaskQueue.self) { _ in
            MissionTaskQueue()
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
