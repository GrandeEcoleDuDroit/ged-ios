import Swinject

class MessageInjector: Injector {
    static var shared: Injector = MessageInjector()
    let container: Container
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        // Api
        container.register(ConversationApi.self) { _ in
            ConversationApiImpl()
        }.inObjectScope(.container)
        
        container.register(MessageServerApi.self) { resolver in
            MessageServerApi(tokenProvider: AppInjector.shared.resolve(TokenProvider.self))
        }.inObjectScope(.container)
        
        container.register(MessageApi.self) { resolver in
            MessageApiImpl(messageServerApi: resolver.resolve(MessageServerApi.self)!)
        }.inObjectScope(.container)
        
        // Data sources
        container.register(ConversationLocalDataSource.self) { resolver in
            ConversationLocalDataSource(gedDatabaseContainer: CommonInjector.shared.resolve(GedDatabaseContainer.self))
        }.inObjectScope(.container)
        
        container.register(ConversationRemoteDataSource.self) { resolver in
            ConversationRemoteDataSource(conversationApi: resolver.resolve(ConversationApi.self)!)
        }.inObjectScope(.container)
        
        container.register(MessageLocalDataSource.self) { resolver in
            MessageLocalDataSource(gedDatabaseContainer: CommonInjector.shared.resolve(GedDatabaseContainer.self))
        }.inObjectScope(.container)
        
        container.register(MessageRemoteDataSource.self) { resolver in
            MessageRemoteDataSource(messageApi: resolver.resolve(MessageApi.self)!)
        }.inObjectScope(.container)
        
        // Repositories
        container.register(ConversationRepository.self) { resolver in
            ConversationRepositoryImpl(
                conversationLocalDataSource: resolver.resolve(ConversationLocalDataSource.self)!,
                conversationRemoteDataSource: resolver.resolve(ConversationRemoteDataSource.self)!
            )
        }.inObjectScope(.container)
        
        container.register(MessageRepository.self) { resolver in
            MessageRepositoryImpl(
                messageLocalDataSource: resolver.resolve(MessageLocalDataSource.self)!,
                messageRemoteDataSource: resolver.resolve(MessageRemoteDataSource.self)!
            )
        }.inObjectScope(.container)
        
        container.register(ConversationMessageRepository.self) { resolver in
            ConversationMessageRepositoryImpl(
                conversationRepository: resolver.resolve(ConversationRepository.self)!,
                messageRepository: resolver.resolve(MessageRepository.self)!
            )
        }.inObjectScope(.container)
        
        // Use cases
        container.register(ListenRemoteConversationsUseCase.self) { resolver in
            ListenRemoteConversationsUseCase(
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                conversationRepository: resolver.resolve(ConversationRepository.self)!,
                listenRemoteMessagesUseCase: resolver.resolve(ListenRemoteMessagesUseCase.self)!
            )
        }.inObjectScope(.container)
        
        container.register(ListenRemoteMessagesUseCase.self) { resolver in
            ListenRemoteMessagesUseCase(
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                conversationRepository: resolver.resolve(ConversationRepository.self)!,
                messageRepository: resolver.resolve(MessageRepository.self)!,
                blockedUserRepository: CommonInjector.shared.resolve(BlockedUserRepository.self)
            )
        }.inObjectScope(.container)
        
        container.register(GetConversationsUiUseCase.self) { resolver in
            GetConversationsUiUseCase(
                conversationMessageRepository: resolver.resolve(ConversationMessageRepository.self)!
            )
        }.inObjectScope(.container)
        
        container.register(GetUnreadConversationsCountUseCase.self) { resolver in
            GetUnreadConversationsCountUseCase(
                conversationMessageRepository: resolver.resolve(ConversationMessageRepository.self)!,
                userRepository: CommonInjector.shared.resolve(UserRepository.self)
            )
        }.inObjectScope(.container)
        
        container.register(GetLocalConversationUseCase.self) { resolver in
            GetLocalConversationUseCase(
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                conversationRepository: resolver.resolve(ConversationRepository.self)!
            )
        }.inObjectScope(.container)
        
        container.register(DeleteConversationUseCase.self) { resolver in
            DeleteConversationUseCase(
                conversationRepository: resolver.resolve(ConversationRepository.self)!,
                messageRepository: resolver.resolve(MessageRepository.self)!,
                conversationMessageRepository: resolver.resolve(ConversationMessageRepository.self)!
            )
        }.inObjectScope(.container)
        
        container.register(SendMessageNotificationUseCase.self) { resolver in
            SendMessageNotificationUseCase(
                notificationApi: CommonInjector.shared.resolve(NotificationApi.self),
                userRepository: CommonInjector.shared.resolve(UserRepository.self)
            )
        }
        
        container.register(SendMessageUseCase.self) { resolver in
            SendMessageUseCase(
                messageRepository: resolver.resolve(MessageRepository.self)!,
                conversationRepository: resolver.resolve(ConversationRepository.self)!,
                sendMessageNotificationUseCase: resolver.resolve(SendMessageNotificationUseCase.self)!
            )
        }.inObjectScope(.container)
        
        container.register(UpdateConversationEffectiveFromUseCase.self) { resolver in
            UpdateConversationEffectiveFromUseCase(
                conversationRepository: resolver.resolve(ConversationRepository.self)!,
                userRepository: CommonInjector.shared.resolve(UserRepository.self)
            )
        }
        
        container.register(RecreateConversationUseCase.self) { resolver in
            RecreateConversationUseCase(conversationRepository: resolver.resolve(ConversationRepository.self)!)
        }
        
        // Others
        container.register(StartupMessageTask.self) { resolver in
            StartupMessageTask(
                networkMonitor: CommonInjector.shared.resolve(NetworkMonitor.self),
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                conversationRepository: resolver.resolve(ConversationRepository.self)!,
                messageRepository: resolver.resolve(MessageRepository.self)!
            )
        }
        
        container.register(MessageNotificationManager.self) { resolver in
            MessageNotificationManager(
                navigationRequestUseCase: CommonInjector.shared.resolve(NavigationRequestUseCase.self),
                routeRepository: CommonInjector.shared.resolve(RouteRepository.self)
            )
        }.inObjectScope(.container)
    }
}
