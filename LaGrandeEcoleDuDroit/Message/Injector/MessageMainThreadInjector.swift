import Swinject

class MessageMainThreadInjector: MainThreadInjector {
    let container: Container
    static var shared: MainThreadInjector = MessageMainThreadInjector()
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        // View models
        container.register(ConversationViewModel.self) { resolver in
            ConversationViewModel(
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                getConversationsUiUseCase: MessageInjector.shared.resolve(GetConversationsUiUseCase.self),
                deleteConversationUseCase: MessageInjector.shared.resolve(DeleteConversationUseCase.self),
                getLocalConversationUseCase: MessageInjector.shared.resolve(GetLocalConversationUseCase.self),
                recreateConversationUseCase: MessageInjector.shared.resolve(RecreateConversationUseCase.self)
            )
        }
        
        container.register(CreateConversationViewModel.self) { resolver in
            CreateConversationViewModel(
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                blockedUserRepository: CommonInjector.shared.resolve(BlockedUserRepository.self),
                getUsersUseCase: CommonInjector.shared.resolve(GetUsersUseCase.self)
            )
        }
        
        container.register(ChatViewModel.self) { (resolver, conversation: Any) in
            let conversation = conversation as! Conversation
            return ChatViewModel(
                conversation: conversation,
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                messageRepository: MessageInjector.shared.resolve(MessageRepository.self),
                conversationRepository: MessageInjector.shared.resolve(ConversationRepository.self),
                sendMessageUseCase: MessageInjector.shared.resolve(SendMessageUseCase.self),
                notificationMessageManager: MessageInjector.shared.resolve(MessageNotificationManager.self),
                networkMonitor: CommonInjector.shared.resolve(NetworkMonitor.self),
                blockedUserRepository: CommonInjector.shared.resolve(BlockedUserRepository.self),
                generateIdUseCase: CommonInjector.shared.resolve(GenerateIdUseCase.self)
            )
        }
        
        container.register(MessageNavigationViewModel.self) { resolver in
            MessageNavigationViewModel(
                routeRepository: CommonInjector.shared.resolve(RouteRepository.self),
                navigationRequestUseCase: CommonInjector.shared.resolve(NavigationRequestUseCase.self)
            )
        }
    }
}
