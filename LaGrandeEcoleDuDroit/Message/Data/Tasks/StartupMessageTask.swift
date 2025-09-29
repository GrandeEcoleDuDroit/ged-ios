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
            let isConnected = await networkMonitor.connected
                .first { $0 }
                .values
                .first { $0 == true } ?? false

            if isConnected {
                await sendUnsentConversationUseCase.execute()
                await sendUnsentMessageUseCase.execute()
            }
        }
    }
}
