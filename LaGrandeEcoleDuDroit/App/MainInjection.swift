import Swinject

class MainInjection: DependencyInjectionContainer {
    static var shared: DependencyInjectionContainer = MainInjection()
    private let container: Container
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        container.register(ListenDataUseCase.self) { resolver in
            ListenDataUseCase(
                listenRemoteMessagesUseCase: MessageInjection.shared.resolve(ListenRemoteMessagesUseCase.self),
                listenRemoteConversationUseCase: MessageInjection.shared.resolve(ListenRemoteConversationUseCase.self)
            )
        }.inObjectScope(.container)
        
        container.register(ClearDataUseCase.self) { resolver in
            ClearDataUseCase(
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
                conversationRepository: MessageInjection.shared.resolve(ConversationRepository.self),
                messageRepository: MessageInjection.shared.resolve(MessageRepository.self)
            )
        }.inObjectScope(.container)
        
        container.register(NavigationViewModel.self) { resolver in
            NavigationViewModel(
                authenticationRepository: AuthenticationInjection.shared.resolve(AuthenticationRepository.self),
                getUnreadConversationsCountUseCase: MessageInjection.shared.resolve(GetUnreadConversationsCountUseCase.self)
                
            )
        }
        
        container.register(MainViewModel.self) { resolver in
            MainViewModel(
                authenticationRepository: AuthenticationInjection.shared.resolve(AuthenticationRepository.self),
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
                listenDataUseCase: resolver.resolve(ListenDataUseCase.self)!,
                clearDataUseCase: resolver.resolve(ClearDataUseCase.self)!
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
        let authenticationMockContainer = AuthenticationInjection.shared.resolveWithMock()
        
        mockContainer.register(MainViewModel.self) { resolver in
            MainViewModel(
                authenticationRepository: authenticationMockContainer.resolve(AuthenticationRepository.self)!,
                userRepository: mockContainer.resolve(UserRepository.self)!,
                listenDataUseCase: resolver.resolve(ListenDataUseCase.self)!,
                clearDataUseCase: resolver.resolve(ClearDataUseCase.self)!
            )
        }
        
        return mockContainer
    }
}
