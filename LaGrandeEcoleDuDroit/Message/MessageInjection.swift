import Swinject

class MessageInjection: DependencyInjectionContainer {
    static var shared: DependencyInjectionContainer = MessageInjection()
    private let container: Container
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        // Api
        container.register(ConversationApi.self) { _ in
            ConversationApiImpl()
        }.inObjectScope(.container)
        
        container.register(MessageApi.self) { _ in
            MessageApiImpl()
        }.inObjectScope(.container)
        
        // Data sources
        
        container.register(ConversationLocalDataSource.self) { resolver in
            ConversationLocalDataSource(gedDatabaseContainer: CommonInjection.shared.resolve(GedDatabaseContainer.self))
        }.inObjectScope(.container)
        
        container.register(ConversationRemoteDataSource.self) { resolver in
            ConversationRemoteDataSource(conversationApi: resolver.resolve(ConversationApi.self)!)
        }.inObjectScope(.container)
        
        container.register(MessageLocalDataSource.self) { resolver in
            MessageLocalDataSource(gedDatabaseContainer: CommonInjection.shared.resolve(GedDatabaseContainer.self))
        }.inObjectScope(.container)
        
        container.register(MessageRemoteDataSource.self) { resolver in
            MessageRemoteDataSource(messageApi: resolver.resolve(MessageApi.self)!)
        }.inObjectScope(.container)
        
        // Repositories
        
        container.register(ConversationRepository.self) { resolver in
            ConversationRepositoryImpl(
                conversationLocalDataSource: resolver.resolve(ConversationLocalDataSource.self)!,
                conversationRemoteDataSource: resolver.resolve(ConversationRemoteDataSource.self)!,
                userRepository: CommonInjection.shared.resolve(UserRepository.self)
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
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
                conversationRepository: resolver.resolve(ConversationRepository.self)!,
                listenRemoteMessagesUseCase: resolver.resolve(ListenRemoteMessagesUseCase.self)!
            )
        }.inObjectScope(.container)
        
        container.register(ListenRemoteMessagesUseCase.self) { resolver in
            ListenRemoteMessagesUseCase(
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
                conversationRepository: resolver.resolve(ConversationRepository.self)!,
                messageRepository: resolver.resolve(MessageRepository.self)!
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
                userRepository: CommonInjection.shared.resolve(UserRepository.self)
            )
        }.inObjectScope(.container)
        
        container.register(GetConversationUseCase.self) { resolver in
            GetConversationUseCase(
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
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
                notificationApi: CommonInjection.shared.resolve(NotificationApi.self),
                userRepository: CommonInjection.shared.resolve(UserRepository.self)
            )
        }
        
        container.register(SendMessageUseCase.self) { resolver in
            SendMessageUseCase(
                messageRepository: resolver.resolve(MessageRepository.self)!,
                conversationRepository: resolver.resolve(ConversationRepository.self)!,
                networkMonitor: CommonInjection.shared.resolve(NetworkMonitor.self),
                sendMessageNotificationUseCase: resolver.resolve(SendMessageNotificationUseCase.self)!
            )
        }.inObjectScope(.container)
        
        // View models
                
        container.register(ConversationViewModel.self) { resolver in
            ConversationViewModel(
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
                getConversationsUiUseCase: resolver.resolve(GetConversationsUiUseCase.self)!,
                deleteConversationUseCase: resolver.resolve(DeleteConversationUseCase.self)!
            )
        }.inObjectScope(.weak)
        
        container.register(CreateConversationViewModel.self) { resolver in
            CreateConversationViewModel(
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
                getLocalConversationUseCase: resolver.resolve(GetConversationUseCase.self)!
            )
        }.inObjectScope(.weak)
        
        container.register(ChatViewModel.self) { (resolver, conversation: Any) in
            let conversation = conversation as! Conversation
            return ChatViewModel(
                conversation: conversation,
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
                messageRepository: resolver.resolve(MessageRepository.self)!,
                conversationRepository: resolver.resolve(ConversationRepository.self)!,
                sendMessageUseCase: resolver.resolve(SendMessageUseCase.self)!,
                notificationMessageManager: resolver.resolve(NotificationMessageManager.self)!
            )
        }
        
        container.register(MessageNavigationViewModel.self) { resolver in
            MessageNavigationViewModel(navigationRequestUseCase: CommonInjection.shared.resolve(NavigationRequestUseCase.self))
        }
        
        // Others
        
        container.register(SynchronizeMessageTask.self) { resolver in
            SynchronizeMessageTask(
                messageRepository: resolver.resolve(MessageRepository.self)!
            )
        }
        
        container.register(SynchronizeConversationTask.self) { resolver in
            SynchronizeConversationTask(
                conversationRepository: resolver.resolve(ConversationRepository.self)!,
                messageRepository: resolver.resolve(MessageRepository.self)!,
                userRepository: CommonInjection.shared.resolve(UserRepository.self)
            )
        }
        
        container.register(MessageTaskLauncher.self) { resolver in
            MessageTaskLauncher(
                networkMonitor: CommonInjection.shared.resolve(NetworkMonitor.self),
                synchronizeMessageTask: resolver.resolve(SynchronizeMessageTask.self)!,
                synchronizeConversationTask: resolver.resolve(SynchronizeConversationTask.self)!
            )
        }
        container.register(NotificationMessageManager.self) { resolver in
            NotificationMessageManager(
                navigationRequestUseCase: CommonInjection.shared.resolve(NavigationRequestUseCase.self),
                routeRepository: CommonInjection.shared.resolve(RouteRepository.self)
            )
        }.inObjectScope(.container)
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
        
        mockContainer.register(ConversationRepository.self) { _ in MockConversationRepository() }
        
        mockContainer.register(ConversationMessageRepository.self) { _ in
            MockConversationMessageRepository()
        }
        
        mockContainer.register(MessageRepository.self) { _ in MockMessageRepository() }
        
        mockContainer.register(SendMessageUseCase.self) { resolver in
            SendMessageUseCase(
                messageRepository: resolver.resolve(MessageRepository.self)!,
                conversationRepository: resolver.resolve(ConversationRepository.self)!,
                networkMonitor: commonMockContainer.resolve(NetworkMonitor.self)!,
                sendMessageNotificationUseCase: resolver.resolve(SendMessageNotificationUseCase.self)!
            )
        }
        
        mockContainer.register(GetUnreadConversationsCountUseCase.self) { resolver in
            GetUnreadConversationsCountUseCase(
                conversationMessageRepository: resolver.resolve(ConversationMessageRepository.self)!,
                userRepository: commonMockContainer.resolve(UserRepository.self)!
            )
        }
        
        mockContainer.register(ConversationViewModel.self) { resolver in
            ConversationViewModel(
                userRepository: commonMockContainer.resolve(UserRepository.self)!,
                getConversationsUiUseCase: resolver.resolve(GetConversationsUiUseCase.self)!,
                deleteConversationUseCase: resolver.resolve(DeleteConversationUseCase.self)!
            )
        }
        
        mockContainer.register(CreateConversationViewModel.self) { resolver in
            CreateConversationViewModel(
                userRepository: commonMockContainer.resolve(UserRepository.self)!,
                getLocalConversationUseCase: resolver.resolve(GetConversationUseCase.self)!
            )
        }
        
        mockContainer.register(ChatViewModel.self) { (resolver, conversation: Conversation) in
            ChatViewModel(
                conversation: conversation,
                userRepository: commonMockContainer.resolve(UserRepository.self)!,
                messageRepository: resolver.resolve(MessageRepository.self)!,
                conversationRepository: resolver.resolve(ConversationRepository.self)!,
                sendMessageUseCase: resolver.resolve(SendMessageUseCase.self)!,
                notificationMessageManager: resolver.resolve(NotificationMessageManager.self)!
            )
        }
        
        return mockContainer
    }
}
