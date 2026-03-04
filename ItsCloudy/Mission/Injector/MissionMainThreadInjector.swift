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
                recreateMissionUseCase: MissionInjector.shared.resolve(RecreateMissionUseCase.self)
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
        
        container.register(EditMissionViewModel.self) { (reolver, mission: Any) in
            let mission = mission as! Mission
            return EditMissionViewModel(
                mission: mission,
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                updateMissionUseCase: MissionInjector.shared.resolve(UpdateMissionUseCase.self),
                getUsersUseCase: CommonInjector.shared.resolve(GetUsersUseCase.self),
                generateIdUseCase: CommonInjector.shared.resolve(GenerateIdUseCase.self)
            )
        }
        
        container.register(SelectManagerViewModel.self) { (resolver, users: Any, previousSelectedManagers: Any) in
            let users = users as! [User]
            let previousSelectedManagers = previousSelectedManagers as! Set<User>
            return SelectManagerViewModel(users: users, previousSelectedManagers: previousSelectedManagers)
        }.inObjectScope(.weak)
        
        container.register(MissionDetailsViewModel.self) { (resolver, missionId: Any) in
            let missionId = missionId as! String
            return MissionDetailsViewModel(
                missionId: missionId,
                missionRepository: MissionInjector.shared.resolve(MissionRepository.self),
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                deleteMissionUseCase: MissionInjector.shared.resolve(DeleteMissionUseCase.self)
            )
        }
        
        container.register(AllUsersViewModel.self) { (resolver, users: Any) in
            let users = users as! [User]
            return AllUsersViewModel(users: users)
        }.inObjectScope(.weak)
    }
}
