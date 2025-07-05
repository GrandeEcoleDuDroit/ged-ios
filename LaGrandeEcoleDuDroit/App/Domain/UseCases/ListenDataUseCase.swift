class ListenDataUseCase {
    private let listenRemoteConversationsUseCase: ListenRemoteConversationsUseCase
    private let listenRemoteUserUseCase: ListenRemoteUserUseCase
    
    init(
        listenRemoteConversationsUseCase: ListenRemoteConversationsUseCase,
        listenRemoteUserUseCase: ListenRemoteUserUseCase
    ) {
        self.listenRemoteConversationsUseCase = listenRemoteConversationsUseCase
        self.listenRemoteUserUseCase = listenRemoteUserUseCase
    }
    
    func start() {
        listenRemoteUserUseCase.start()
        listenRemoteConversationsUseCase.start()
    }
    
    func stop() {
        listenRemoteUserUseCase.stop()
        listenRemoteConversationsUseCase.stop()
    }
}
