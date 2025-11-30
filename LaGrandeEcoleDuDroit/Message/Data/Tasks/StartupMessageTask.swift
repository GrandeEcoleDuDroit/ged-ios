import Combine

class StartupMessageTask {
    private let networkMonitor: NetworkMonitor
    private let sendUnsentMessageUseCase: SendUnsentMessageUseCase
    private let sendUnsentConversationUseCase: SendUnsentConversationUseCase
    
    init(
        networkMonitor: NetworkMonitor,
        sendUnsentMessageUseCase: SendUnsentMessageUseCase,
        sendUnsentConversationUseCase: SendUnsentConversationUseCase
    ) {
        self.networkMonitor = networkMonitor
        self.sendUnsentMessageUseCase = sendUnsentMessageUseCase
        self.sendUnsentConversationUseCase = sendUnsentConversationUseCase
    }
    
    func run() {
        Task {
            await networkMonitor.connected.values.first { $0 }
            await sendUnsentConversationUseCase.execute()
            await sendUnsentMessageUseCase.execute()
        }
    }
}
