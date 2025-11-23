import Swinject

class MissionMainThreadInjector: MainThreadInjector {
    let container: Container
    static var shared: MainThreadInjector = MissionMainThreadInjector()
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        // View models
        container.register(MissionNavigationViewModel.self) { _ in
            MissionNavigationViewModel(
                routeRepository: CommonInjector.shared.resolve(RouteRepository.self)
            )
        }

        container.register(MissionViewModel.self) { _ in
            MissionViewModel(
                missionRepository: MissionInjector.shared.resolve(MissionRepository.self),
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                refreshMissionsUseCase: MissionInjector.shared.resolve(RefreshMissionsUseCase.self),
                deleteMissionUseCase: MissionInjector.shared.resolve(DeleteMissionUseCase.self),
                networkMonitor: CommonInjector.shared.resolve(NetworkMonitor.self)
            )
        }
        
        container.register(CreateMissionViewModel.self) { _ in
            CreateMissionViewModel(
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                createMissionUseCase: MissionInjector.shared.resolve(CreateMissionUseCase.self),
                getUsersUseCase: CommonInjector.shared.resolve(GetUsersUseCase.self),
                generateIdUseCase: CommonInjector.shared.resolve(GenerateIdUseCase.self)
            )
        }
    }
}
