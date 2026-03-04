class ListenDataUseCase {
    private let listenRemoteConversationsUseCase: ListenRemoteConversationsUseCase
    private let listenRemoteUserUseCase: ListenRemoteUserUseCase
    private let listenRemoteMessagesUseCase: ListenRemoteMessagesUseCase
    private let listenBlockedUserEventsUseCase: ListenBlockedUserEventsUseCase
    
    init(
        listenRemoteConversationsUseCase: ListenRemoteConversationsUseCase,
        listenRemoteUserUseCase: ListenRemoteUserUseCase,
        listenRemoteMessagesUseCase: ListenRemoteMessagesUseCase,
        listenBlockedUserEventsUseCase: ListenBlockedUserEventsUseCase
    ) {
        self.listenRemoteConversationsUseCase = listenRemoteConversationsUseCase
        self.listenRemoteUserUseCase = listenRemoteUserUseCase
        self.listenRemoteMessagesUseCase = listenRemoteMessagesUseCase
        self.listenBlockedUserEventsUseCase = listenBlockedUserEventsUseCase
    }
    
    func start() {
        listenRemoteUserUseCase.start()
        listenRemoteConversationsUseCase.start()
        listenBlockedUserEventsUseCase.start()
    }
    
    func stop() {
        listenRemoteUserUseCase.stop()
        listenRemoteConversationsUseCase.stop()
        listenRemoteMessagesUseCase.stopAll()
    }
}
