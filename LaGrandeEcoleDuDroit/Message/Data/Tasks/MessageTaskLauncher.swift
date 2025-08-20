import Combine

class MessageTaskLauncher {
    private let networkMonitor: NetworkMonitor
    private let synchronizeMessageTask: SynchronizeMessageTask
    private let synchronizeConversationTask: SynchronizeConversationTask
    private var cancellable: AnyCancellable?
    
    init(
        networkMonitor: NetworkMonitor,
        synchronizeMessageTask: SynchronizeMessageTask,
        synchronizeConversationTask: SynchronizeConversationTask
    ) {
        self.networkMonitor = networkMonitor
        self.synchronizeMessageTask = synchronizeMessageTask
        self.synchronizeConversationTask = synchronizeConversationTask
    }
    
    func launch() {
        cancellable = networkMonitor.connected.sink { [weak self] status in
            Task {
                await self?.synchronizeConversationTask.start()
                await self?.synchronizeMessageTask.start()
                self?.cancellable?.cancel()
            }
        }
    }
}
