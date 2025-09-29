class SynchronizeDataUseCase {
    private let synchronizeBlockedUsersUseCase: SynchronizeBlockedUsersUseCase
    private let synchronizeAnnouncementsUseCase: SynchronizeAnnouncementsUseCase
    private let tag = String(describing: SynchronizeDataUseCase.self)
    
    init(
        synchronizeBlockedUsersUseCase: SynchronizeBlockedUsersUseCase,
        synchronizeAnnouncementsUseCase: SynchronizeAnnouncementsUseCase
    ) {
        self.synchronizeBlockedUsersUseCase = synchronizeBlockedUsersUseCase
        self.synchronizeAnnouncementsUseCase = synchronizeAnnouncementsUseCase
    }
    
    func execute() async {
        do {
            try await synchronizeBlockedUsersUseCase.execute()
            try await synchronizeAnnouncementsUseCase.execute()
        } catch {
            e(tag, "Failed to synchronize data: \(error)", error)
        }
    }
}
