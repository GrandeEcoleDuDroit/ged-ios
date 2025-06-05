class DataListeningUseCase {
    private let listenRemoteConversationsMessagesUseCase: ListenRemoteConversationsMessagesUseCase
    
    init(
        listenRemoteConversationsMessagesUseCase: ListenRemoteConversationsMessagesUseCase,
    ) {
        self.listenRemoteConversationsMessagesUseCase = listenRemoteConversationsMessagesUseCase
    }
    
    func start() {
        listenRemoteConversationsMessagesUseCase.start()
    }
    
    func stop() {
        listenRemoteConversationsMessagesUseCase.stop()
    }
}
