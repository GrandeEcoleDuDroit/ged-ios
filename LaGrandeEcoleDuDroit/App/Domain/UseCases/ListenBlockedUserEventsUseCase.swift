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
                case let .block(userId, _):
                    Task {
                        if let conversation = await self?.conversationRepository.getLocalConversation(interlocutorId: userId) {
                            self?.listenRemoteMessagesUseCase.stop(conversationId: conversation.id)
                        }
                    }
                    
                    Task {
                        try? await self?.announcementRepository.deleteLocalAnnouncements(userId: userId)
                    }
                    
                case let .unblock(userId, date):
                    Task {
                        await self?.updateConversationEffectiveFromUseCase.execute(userId: userId, effectiveFrom: date)
                    }
            }
        }.store(in: &cancellables)
    }
}
