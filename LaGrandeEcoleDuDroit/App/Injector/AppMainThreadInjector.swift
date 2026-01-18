import Swinject

class AppMainThreadInjector: MainThreadInjector {
    let container: Container
    static var shared: MainThreadInjector = AppMainThreadInjector()
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        // View models
        container.register(NavigationHostViewModel.self) { resolver in
            NavigationHostViewModel(
                authenticationRepository: AuthenticationInjector.shared.resolve(AuthenticationRepository.self)
            )
        }
        
        container.register(AppNavigationViewModel.self) { resolver in
            AppNavigationViewModel(
                getUnreadConversationsCountUseCase: MessageInjector.shared.resolve(GetUnreadConversationsCountUseCase.self),
                navigationRequestUseCase: CommonInjector.shared.resolve(NavigationRequestUseCase.self)
                
            )
        }
        
        container.register(ProfileViewModel.self) { resolver in
            ProfileViewModel(
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                logoutUseCase: AuthenticationInjector.shared.resolve(LogoutUseCase.self)
            )
        }
        
        container.register(ProfileNavigationViewModel.self) { resolver in
            ProfileNavigationViewModel(
                routeRepository: CommonInjector.shared.resolve(RouteRepository.self)
            )
        }
        
        container.register(AccountInformationViewModel.self) { resolver in
            AccountInformationViewModel(
                updateProfilePictureUseCase: CommonInjector.shared.resolve(UpdateProfilePictureUseCase.self),
                userRepository: CommonInjector.shared.resolve(UserRepository.self)
            )
        }
        
        container.register(DeleteAccountViewModel.self) { resolver in
            DeleteAccountViewModel(
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                deleteUserAccountUseCase: AppInjector.shared.resolve(DeleteAccountUseCase.self)
            )
        }
        
        container.register(BlockedUsersViewModel.self) { resolver in
            BlockedUsersViewModel(
                blockedUserRepository: CommonInjector.shared.resolve(BlockedUserRepository.self),
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                getBlockedUsersUseCase: CommonInjector.shared.resolve(GetBlockedUsersUseCase.self)
            )
        }
    }
}
