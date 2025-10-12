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
                listenAuthenticationStateUseCase: AuthenticationInjector.shared.resolve(ListenAuthenticationStateUseCase.self)
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
                authenticationRepository: AuthenticationInjector.shared.resolve(AuthenticationRepository.self)
            )
        }
        
        container.register(AccountInformationViewModel.self) { resolver in
            AccountInformationViewModel(
                updateProfilePictureUseCase: CommonInjector.shared.resolve(UpdateProfilePictureUseCase.self),
                deleteProfilePictureUseCase: CommonInjector.shared.resolve(DeleteProfilePictureUseCase.self),
                networkMonitor: CommonInjector.shared.resolve(NetworkMonitor.self),
                userRepository: CommonInjector.shared.resolve(UserRepository.self)
            )
        }
        
        container.register(DeleteAccountViewModel.self) { resolver in
            DeleteAccountViewModel(
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                networkMonitor: CommonInjector.shared.resolve(NetworkMonitor.self),
                deleteUserAccountUseCase: AppInjector.shared.resolve(DeleteUserAccountUseCase.self)
            )
        }
        
        container.register(BlockedUsersViewModel.self) { resolver in
            BlockedUsersViewModel(
                blockedUserRepository: CommonInjector.shared.resolve(BlockedUserRepository.self),
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                networkMonitor: CommonInjector.shared.resolve(NetworkMonitor.self)
            )
        }
    }
}
