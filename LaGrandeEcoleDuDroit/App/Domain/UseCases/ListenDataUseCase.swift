class ListenDataUseCase {
    private let listenRemoteConversationUseCase: ListenRemoteConversationUseCase
    private let listenRemoteMessagesUseCase: ListenRemoteMessagesUseCase
    
    init(
        listenRemoteMessagesUseCase: ListenRemoteMessagesUseCase,
        listenRemoteConversationUseCase: ListenRemoteConversationUseCase
    ) {
        self.listenRemoteMessagesUseCase = listenRemoteMessagesUseCase
        self.listenRemoteConversationUseCase = listenRemoteConversationUseCase
    }
    
    func start() {
        listenRemoteConversationUseCase.start()
//        listenRemoteMessagesUseCase.start()
    }
    
    func stop() {
        listenRemoteConversationUseCase.stop()
        listenRemoteMessagesUseCase.stop()
    }
}
