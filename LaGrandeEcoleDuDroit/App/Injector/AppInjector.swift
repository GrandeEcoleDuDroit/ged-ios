import Swinject

class AppInjector: Injector {
    static var shared: Injector = AppInjector()
    let container: Container
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        // Use cases
        container.register(ListenRemoteUserUseCase.self) { resolver in
            ListenRemoteUserUseCase(
                authenticationRepository: AuthenticationInjector.shared.resolve(AuthenticationRepository.self),
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
            )
        }.inObjectScope(.container)
        
        container.register(ListenBlockedUserEventsUseCase.self) { resolver in
            ListenBlockedUserEventsUseCase(
                blockedUserRepository: CommonInjector.shared.resolve(BlockedUserRepository.self),
                announcementRepository: NewsInjector.shared.resolve(AnnouncementRepository.self),
                listenRemoteMessagesUseCase: MessageInjector.shared.resolve(ListenRemoteMessagesUseCase.self),
                updateConversationDeleteTimeUseCase: MessageInjector.shared.resolve(UpdateConversationDeleteTimeUseCase.self)
            )
        }.inObjectScope(.container)
        
        container.register(ListenDataUseCase.self) { resolver in
            ListenDataUseCase(
                listenRemoteConversationsUseCase: MessageInjector.shared.resolve(ListenRemoteConversationsUseCase.self),
                listenRemoteUserUseCase: resolver.resolve(ListenRemoteUserUseCase.self)!,
                listenRemoteMessagesUseCase: MessageInjector.shared.resolve(ListenRemoteMessagesUseCase.self),
                listenBlockedUserEventsUseCase: resolver.resolve(ListenBlockedUserEventsUseCase.self)!
            )
        }
        
        container.register(ClearDataUseCase.self) { resolver in
            ClearDataUseCase(
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                conversationRepository: MessageInjector.shared.resolve(ConversationRepository.self),
                messageRepository: MessageInjector.shared.resolve(MessageRepository.self),
                conversationMessageRepository: MessageInjector.shared.resolve(ConversationMessageRepository.self),
                announcementRepository: NewsInjector.shared.resolve(AnnouncementRepository.self)
            )
        }
        
        container.register(FcmTokenUseCase.self) { resolver in
            FcmTokenUseCase(
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                fcmTokenRepository: CommonInjector.shared.resolve(FcmTokenRepository.self),
                networkMonitor: CommonInjector.shared.resolve(NetworkMonitor.self),
                listenAuthenticationStateUseCase: AuthenticationInjector.shared.resolve(ListenAuthenticationStateUseCase.self)
            )
        }.inObjectScope(.container)
        
        container.register(DeleteAccountUseCase.self) { resolver in
            DeleteAccountUseCase(
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                authenticationRepository: AuthenticationInjector.shared.resolve(AuthenticationRepository.self),
                announcementRepository: NewsInjector.shared.resolve(AnnouncementRepository.self),
                imageRepository: CommonInjector.shared.resolve(ImageRepository.self)
            )
        }
        
        container.register(SynchronizeDataUseCase.self) { resolver in
            SynchronizeDataUseCase(
                synchronizeBlockedUsersUseCase: CommonInjector.shared.resolve(SynchronizeBlockedUsersUseCase.self),
                synchronizeAnnouncementsUseCase: NewsInjector.shared.resolve(SynchronizeAnnouncementsUseCase.self),
                synchronizeMissionsUseCase: MissionInjector.shared.resolve(SynchronizeMissionsUseCase.self),
                networkMonitor: CommonInjector.shared.resolve(NetworkMonitor.self)
            )
        }
        
        container.register(CheckUserValidityUseCase.self) { resolver in
            CheckUserValidityUseCase(
                authenticationRepository: AuthenticationInjector.shared.resolve(AuthenticationRepository.self),
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                networkMonitor: CommonInjector.shared.resolve(NetworkMonitor.self)
            )
        }
        
        // View models
        container.register(MainViewModel.self) { resolver in
            MainViewModel(
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                listenDataUseCase: resolver.resolve(ListenDataUseCase.self)!,
                clearDataUseCase: resolver.resolve(ClearDataUseCase.self)!,
                listenAuthenticationStateUseCase: AuthenticationInjector.shared.resolve(ListenAuthenticationStateUseCase.self),
                synchronizeDataUseCase: resolver.resolve(SynchronizeDataUseCase.self)!,
                checkUserValidityUseCase: resolver.resolve(CheckUserValidityUseCase.self)!
            )
        }
        
        // Others
        container.register(NotificationMediator.self) { resolver in
            NotificationMediatorImpl(
                messageNotificationManager: MessageInjector.shared.resolve(MessageNotificationManager.self)
            )
        }.inObjectScope(.container)
        
        container.register(FcmManager.self) { resolver in
            FcmManager()
        }.inObjectScope(.container)
        
        container.register(TokenProvider.self) { resolver in
            TokenProviderImpl(authenticationRepository: AuthenticationInjector.shared.resolve(AuthenticationRepository.self))
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
}
