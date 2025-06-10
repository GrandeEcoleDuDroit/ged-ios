class ListenDataUseCase {
    private let listenRemoteConversationsUseCase: ListenRemoteConversationsUseCase
    private let listenRemoteMessagesUseCase: ListenRemoteMessagesUseCase
    private let listenRemoteUserUseCase: ListenRemoteUserUseCase
    
    init(
        listenRemoteMessagesUseCase: ListenRemoteMessagesUseCase,
        listenRemoteConversationsUseCase: ListenRemoteConversationsUseCase,
        listenRemoteUserUseCase: ListenRemoteUserUseCase
    ) {
        self.listenRemoteMessagesUseCase = listenRemoteMessagesUseCase
        self.listenRemoteConversationsUseCase = listenRemoteConversationsUseCase
        self.listenRemoteUserUseCase = listenRemoteUserUseCase
    }
    
    func start() {
        listenRemoteConversationsUseCase.start()
        listenRemoteMessagesUseCase.start()
        listenRemoteUserUseCase.start()
    }
    
    func stop() {
        listenRemoteConversationsUseCase.stop()
        listenRemoteMessagesUseCase.stop()
        listenRemoteUserUseCase.stop()
    }
}
