import Combine

class ListenBlockedUserEventsUseCase {
    private let blockedUserRepository: BlockedUserRepository
    private let announcementRepository: AnnouncementRepository
    private let conversationRepository: ConversationRepository
    private let listenRemoteMessagesUseCase: ListenRemoteMessagesUseCase
    private let updateConversationEffectiveFromUseCase: UpdateConversationEffectiveFromUseCase
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        blockedUserRepository: BlockedUserRepository,
        announcementRepository: AnnouncementRepository,
        conversationRepository: ConversationRepository,
        listenRemoteMessagesUseCase: ListenRemoteMessagesUseCase,
        updateConversationEffectiveFromUseCase: UpdateConversationEffectiveFromUseCase
    ) {
        self.blockedUserRepository = blockedUserRepository
        self.announcementRepository = announcementRepository
        self.conversationRepository = conversationRepository
        self.listenRemoteMessagesUseCase = listenRemoteMessagesUseCase
        self.updateConversationEffectiveFromUseCase = updateConversationEffectiveFromUseCase
    }
    
    func start() {
        blockedUserRepository.blockedUserEvents.sink { [weak self] event in
            switch event {
                case let .block(blockedUser):
                    Task {
                        try? await self?.announcementRepository.deleteLocalUserAnnouncements(userId: blockedUser.userId)
                    }
                
                default: break
            }
        }.store(in: &cancellables)
    }
}
