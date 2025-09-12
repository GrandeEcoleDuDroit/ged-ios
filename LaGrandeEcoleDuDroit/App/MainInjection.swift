import Swinject

class MainInjection: DependencyInjectionContainer {
    static var shared: DependencyInjectionContainer = MainInjection()
    private let container: Container
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        // Use cases
        
        container.register(ListenRemoteUserUseCase.self) { resolver in
            ListenRemoteUserUseCase(
                authenticationRepository: AuthenticationInjection.shared.resolve(AuthenticationRepository.self),
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
            )
        }.inObjectScope(.container)
        
        container.register(ListenDataUseCase.self) { resolver in
            ListenDataUseCase(
                listenRemoteConversationsUseCase: MessageInjection.shared.resolve(ListenRemoteConversationsUseCase.self),
                listenRemoteUserUseCase: resolver.resolve(ListenRemoteUserUseCase.self)!
            )
        }
        
        container.register(ClearDataUseCase.self) { resolver in
            ClearDataUseCase(
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
                conversationRepository: MessageInjection.shared.resolve(ConversationRepository.self),
                messageRepository: MessageInjection.shared.resolve(MessageRepository.self),
                conversationMessageRepository: MessageInjection.shared.resolve(ConversationMessageRepository.self)
            )
        }
        
        container.register(FcmTokenUseCase.self) { resolver in
            FcmTokenUseCase(
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
                authenticationRepository: AuthenticationInjection.shared.resolve(AuthenticationRepository.self),
                fcmTokenRepository: CommonInjection.shared.resolve(FcmTokenRepository.self),
                networkMonitor: CommonInjection.shared.resolve(NetworkMonitor.self)
            )
        }.inObjectScope(.container)
        
        container.register(DeleteUserAccountUseCase.self) { resolver in
            DeleteUserAccountUseCase(
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
                authenticationRepository: AuthenticationInjection.shared.resolve(AuthenticationRepository.self)
            )
        }
        
        // View models
        
        container.register(NavigationHostViewModel.self) { resolver in
            NavigationHostViewModel(
                authenticationRepository: AuthenticationInjection.shared.resolve(AuthenticationRepository.self)
            )
        }
        
        container.register(AppNavigationViewModel.self) { resolver in
            AppNavigationViewModel(
                getUnreadConversationsCountUseCase: MessageInjection.shared.resolve(GetUnreadConversationsCountUseCase.self),
                navigationRequestUseCase: CommonInjection.shared.resolve(NavigationRequestUseCase.self)
                
            )
        }
        
        container.register(MainViewModel.self) { resolver in
            MainViewModel(
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
                authenticationRepository: AuthenticationInjection.shared.resolve(AuthenticationRepository.self),
                listenDataUseCase: resolver.resolve(ListenDataUseCase.self)!,
                clearDataUseCase: resolver.resolve(ClearDataUseCase.self)!
            )
        }
        
        container.register(ProfileNavigationViewModel.self) { resolver in
            ProfileNavigationViewModel(
                routeRepository: CommonInjection.shared.resolve(RouteRepository.self)
            )
        }
        
        container.register(ProfileViewModel.self) { resolver in
            ProfileViewModel(
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
                authenticationRepository: AuthenticationInjection.shared.resolve(AuthenticationRepository.self)
            )
        }
        
        container.register(AccountInformationViewModel.self) { resolver in
            AccountInformationViewModel(
                updateProfilePictureUseCase: CommonInjection.shared.resolve(UpdateProfilePictureUseCase.self),
                deleteProfilePictureUseCase: CommonInjection.shared.resolve(DeleteProfilePictureUseCase.self),
                networkMonitor: CommonInjection.shared.resolve(NetworkMonitor.self),
                userRepository: CommonInjection.shared.resolve(UserRepository.self)
            )
        }
        
        container.register(DeleteAccountViewModel.self) { resolver in
            DeleteAccountViewModel(
                networkMonitor: CommonInjection.shared.resolve(NetworkMonitor.self),
                deleteUserAccountUseCase: resolver.resolve(DeleteUserAccountUseCase.self)!
            )
        }
        
        // Others
        
        container.register(NotificationMediator.self) { resolver in
            NotificationMediatorImpl(
                messageNotificationManager: MessageInjection.shared.resolve(MessageNotificationManager.self)
            )
        }.inObjectScope(.container)
        
        container.register(FcmManager.self) { resolver in
            FcmManager()
        }.inObjectScope(.container)
        
        container.register(TokenProvider.self) { resolver in
            TokenProviderImpl(firebaseAuthenticationRepository: AuthenticationInjection.shared.resolve(FirebaseAuthenticationRepository.self))
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
        let authenticationMockContainer = AuthenticationInjection.shared.resolveWithMock()
        let messageMockContainer = MessageInjection.shared.resolveWithMock()
        
        mockContainer.register(MainViewModel.self) { resolver in
            MainViewModel(
                userRepository: commonMockContainer.resolve(UserRepository.self)!,
                authenticationRepository: authenticationMockContainer.resolve(AuthenticationRepository.self)!,
                listenDataUseCase: resolver.resolve(ListenDataUseCase.self)!,
                clearDataUseCase: resolver.resolve(ClearDataUseCase.self)!
            )
        }
        
        mockContainer.register(AppNavigationViewModel.self) { resolver in
            AppNavigationViewModel(
                getUnreadConversationsCountUseCase: messageMockContainer.resolve(GetUnreadConversationsCountUseCase.self)!,
                navigationRequestUseCase: commonMockContainer.resolve(NavigationRequestUseCase.self)!
            )
        }
        
        mockContainer.register(ProfileViewModel.self) { resolver in
            ProfileViewModel(
                userRepository: commonMockContainer.resolve(UserRepository.self)!,
                authenticationRepository: authenticationMockContainer.resolve(AuthenticationRepository.self)!
            )
        }
        
        mockContainer.register(AccountInformationViewModel.self) { resolver in
            AccountInformationViewModel(
                updateProfilePictureUseCase: commonMockContainer.resolve(UpdateProfilePictureUseCase.self)!,
                deleteProfilePictureUseCase: commonMockContainer.resolve(DeleteProfilePictureUseCase.self)!,
                networkMonitor: commonMockContainer.resolve(NetworkMonitor.self)!,
                userRepository: commonMockContainer.resolve(UserRepository.self)!,
            )
        }
        
        
        return mockContainer
    }
}
