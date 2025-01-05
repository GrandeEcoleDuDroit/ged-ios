import Swinject

class MessageDependencyInjectionContainer: DependencyInjectionContainer {
    static var shared: DependencyInjectionContainer = MessageDependencyInjectionContainer()
    private let container: Container
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        container.register(ConversationApi.self) { _ in ConversationApiImpl() }
            .inObjectScope(.container)
        container.register(MessageApi.self) { _ in MessageApiImpl() }
            .inObjectScope(.container)
        container.register(ConversationLocalDataSource.self) { resolver in
            ConversationLocalDataSource(gedDatabaseContainer: CommonDependencyInjectionContainer.shared.resolve(GedDatabaseContainer.self))
        }
        .inObjectScope(.container)
        container.register(ConversationRemoteDataSource.self) { resolver in
            ConversationRemoteDataSource(conversationApi: resolver.resolve(ConversationApi.self)!)
        }
        .inObjectScope(.container)
        container.register(MessageLocalDataSource.self) { resolver in
            MessageLocalDataSource(gedDatabaseContainer: CommonDependencyInjectionContainer.shared.resolve(GedDatabaseContainer.self))
        }
        .inObjectScope(.container)
        container.register(MessageRemoteDataSource.self) { resolver in
            MessageRemoteDataSource(messageApi: resolver.resolve(MessageApi.self)!)
        }
        .inObjectScope(.container)
        container.register(ConversationRepository.self) { resolver in
            ConversationRepositoryImpl(
                conversationLocalDataSource: resolver.resolve(ConversationLocalDataSource.self)!,
                conversationRemoteDataSource: resolver.resolve(ConversationRemoteDataSource.self)!
            )
        }
        .inObjectScope(.container)
        container.register(UserConversationRepository.self) { resolver in
            UserConversationRepositoryImpl(
                userRepository: CommonDependencyInjectionContainer.shared.resolve(UserRepository.self),
                conversationRepository: resolver.resolve(ConversationRepository.self)!
            )
        }
        .inObjectScope(.container)
        container.register(MessageRepository.self) { resolver in
            MessageRepositoryImpl(
                messageLocalDataSource: resolver.resolve(MessageLocalDataSource.self)!,
                messageRemoteDataSource: resolver.resolve(MessageRemoteDataSource.self)!
            )
        }
        .inObjectScope(.container)
        
        container.register(GetMessagesUseCase.self) { resolver in
            GetMessagesUseCase(
                messageRepository: resolver.resolve(MessageRepository.self)!
            )
        }
        container.register(GetLastMessagesUseCase.self) { resolver in
            GetLastMessagesUseCase(
                messageRepository: resolver.resolve(MessageRepository.self)!
            )
        }
        container.register(GetConversationsUserUseCase.self) { resolver in
            GetConversationsUserUseCase(
                userConversationRepository: resolver.resolve(UserConversationRepository.self)!
            )
        }
        container.register(GetConversationsUIUseCase.self) { resolver in
            GetConversationsUIUseCase(
                getConversationsUserUseCase: resolver.resolve(GetConversationsUserUseCase.self)!,
                getLastMessagesUseCase: resolver.resolve(GetLastMessagesUseCase.self)!
            )
        }
        container.register(CreateConversationUseCase.self) { resolver in
            CreateConversationUseCase(
                userConversationRepository: resolver.resolve(UserConversationRepository.self)!
            )
        }
        .inObjectScope(.graph)
        container.register(DeleteConversationUseCase.self) { resolver in
            DeleteConversationUseCase(
                userConversationRepository: resolver.resolve(UserConversationRepository.self)!
            )
        }
        .inObjectScope(.graph)
        
        container.register(ConversationViewModel.self) { resolver in
            ConversationViewModel(
                getConversationsUIUseCase: resolver.resolve(GetConversationsUIUseCase.self)!,
                deleteConversationUseCase: resolver.resolve(DeleteConversationUseCase.self)!
            )
        }
        container.register(CreateConversationViewModel.self) { resolver in
            CreateConversationViewModel(
                getUsersUseCase: CommonDependencyInjectionContainer.shared.resolve(GetUsersUseCase.self),
                getCurrentUserUseCase: CommonDependencyInjectionContainer.shared.resolve(GetCurrentUserUseCase.self),
                getFilteredUsersUseCase: CommonDependencyInjectionContainer.shared.resolve(GetFilteredUsersUseCase.self),
                generateIdUseCase: CommonDependencyInjectionContainer.shared.resolve(GenerateIdUseCase.self)
            )
        }
        container.register(ChatViewModel.self) { (resolver, conversation: ConversationUI) in
            ChatViewModel(
                getMessagesUseCase: resolver.resolve(GetMessagesUseCase.self)!,
                getCurrentUserUseCase: CommonDependencyInjectionContainer.shared.resolve(GetCurrentUserUseCase.self),
                generateIdUseCase: CommonDependencyInjectionContainer.shared.resolve(GenerateIdUseCase.self),
                createConversationUseCase: resolver.resolve(CreateConversationUseCase.self)!,
                conversation: conversation
            )
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
        let commonMockContainer = CommonDependencyInjectionContainer.shared.resolveWithMock()
        
        mockContainer.register(UserConversationRepository.self) { _ in MockUserConversationRepository() }
        mockContainer.register(MessageRepository.self) { _ in MockMessageRepository() }
        
        mockContainer.register(GetMessagesUseCase.self) { resolver in
            GetMessagesUseCase(messageRepository: resolver.resolve(MessageRepository.self)!)
        }
        mockContainer.register(GetLastMessagesUseCase.self) { resolver in
            GetLastMessagesUseCase(messageRepository: resolver.resolve(MessageRepository.self)!)
        }
        mockContainer.register(GetConversationsUserUseCase.self) { resolver in
            GetConversationsUserUseCase(userConversationRepository: resolver.resolve(UserConversationRepository.self)!)
        }
        mockContainer.register(GetConversationsUIUseCase.self) { resolver in
            GetConversationsUIUseCase(
                getConversationsUserUseCase: resolver.resolve(GetConversationsUserUseCase.self)!,
                getLastMessagesUseCase: resolver.resolve(GetLastMessagesUseCase.self)!
            )
        }
        mockContainer.register(CreateConversationUseCase.self) { resolver in
            CreateConversationUseCase(userConversationRepository: resolver.resolve(UserConversationRepository.self)!)
        }
        mockContainer.register(DeleteConversationUseCase.self) { resolver in
            DeleteConversationUseCase(userConversationRepository: resolver.resolve(UserConversationRepository.self)!)
        }
        
        mockContainer.register(ConversationViewModel.self) { resolver in
            ConversationViewModel(
                getConversationsUIUseCase: resolver.resolve(GetConversationsUIUseCase.self)!,
                deleteConversationUseCase: resolver.resolve(DeleteConversationUseCase.self)!
            )
        }
        mockContainer.register(CreateConversationViewModel.self) { resolver in
            CreateConversationViewModel(
                getUsersUseCase: commonMockContainer.resolve(GetUsersUseCase.self)!,
                getCurrentUserUseCase: commonMockContainer.resolve(GetCurrentUserUseCase.self)!,
                getFilteredUsersUseCase: commonMockContainer.resolve(GetFilteredUsersUseCase.self)!,
                generateIdUseCase: commonMockContainer.resolve(GenerateIdUseCase.self)!
            )
        }
        mockContainer.register(ChatViewModel.self) { (resolver, conversation: ConversationUI) in
            ChatViewModel(
                getMessagesUseCase: resolver.resolve(GetMessagesUseCase.self)!,
                getCurrentUserUseCase: commonMockContainer.resolve(GetCurrentUserUseCase.self)!,
                generateIdUseCase: commonMockContainer.resolve(GenerateIdUseCase.self)!,
                createConversationUseCase: resolver.resolve(CreateConversationUseCase.self)!,
                conversation: conversation
            )
        }
        
        return mockContainer
    }
}
