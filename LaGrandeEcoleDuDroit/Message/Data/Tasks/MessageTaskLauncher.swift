import Combine

class MessageTaskLauncher {
    private let networkMonitor: NetworkMonitor
    private let synchronizeMessagesTask: SynchronizeMessageTask
    private let synchronizeConversationsTask: SynchronizeConversationTask
    private var cancellable: AnyCancellable?
    
    init(
        networkMonitor: NetworkMonitor,
        synchronizeMessagesTask: SynchronizeMessageTask,
        synchronizeConversationsTask: SynchronizeConversationTask
    ) {
        self.networkMonitor = networkMonitor
        self.synchronizeMessagesTask = synchronizeMessagesTask
        self.synchronizeConversationsTask = synchronizeConversationsTask
    }
    
    func launch() async {
        for await status in networkMonitor.connectionStatus.values {
            if status {
                await synchronizeConversationsTask.start()
                await synchronizeMessagesTask.start()
                break
            }
        }
    }
}
