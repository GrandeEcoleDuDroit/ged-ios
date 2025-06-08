class ListenDataUseCase {
    private let listenRemoteConversationsUseCase: ListenRemoteConversationsUseCase
    private let listenRemoteMessagesUseCase: ListenRemoteMessagesUseCase
    
    init(
        listenRemoteMessagesUseCase: ListenRemoteMessagesUseCase,
        listenRemoteConversationsUseCase: ListenRemoteConversationsUseCase
    ) {
        self.listenRemoteMessagesUseCase = listenRemoteMessagesUseCase
        self.listenRemoteConversationsUseCase = listenRemoteConversationsUseCase
    }
    
    func start() {
        listenRemoteConversationsUseCase.start()
        listenRemoteMessagesUseCase.start()
    }
    
    func stop() {
        listenRemoteConversationsUseCase.stop()
        listenRemoteMessagesUseCase.stop()
    }
}
