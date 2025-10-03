import Combine

class ListenBlockedUserEventsUseCase {
    private let blockedUserRepository: BlockedUserRepository
    private let announcementRepository: AnnouncementRepository
    private let listenRemoteMessagesUseCase: ListenRemoteMessagesUseCase
    private let updateConversationDeleteTimeUseCase: UpdateConversationDeleteTimeUseCase
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        blockedUserRepository: BlockedUserRepository,
        announcementRepository: AnnouncementRepository,
        listenRemoteMessagesUseCase: ListenRemoteMessagesUseCase,
        updateConversationDeleteTimeUseCase: UpdateConversationDeleteTimeUseCase
    ) {
        self.blockedUserRepository = blockedUserRepository
        self.announcementRepository = announcementRepository
        self.listenRemoteMessagesUseCase = listenRemoteMessagesUseCase
        self.updateConversationDeleteTimeUseCase = updateConversationDeleteTimeUseCase
    }
    
    func start() {
        blockedUserRepository.blockedUserEvents.sink { [weak self] event in
            switch event {
                case let .block(userId, _):
                    self?.listenRemoteMessagesUseCase.stop(userId: userId)
                    Task {
                        try? await self?.announcementRepository.deleteLocalUserAnnouncements(userId: userId)
                    }
                    
                case let .unblock(userId, date):
                    Task {
                        try? await self?.updateConversationDeleteTimeUseCase.execute(userId: userId, deleteTime: date)
                    }
            }
        }.store(in: &cancellables)
    }
}
