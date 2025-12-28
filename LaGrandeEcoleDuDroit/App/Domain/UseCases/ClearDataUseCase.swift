class ClearDataUseCase {
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    private let conversationMessageRepository: ConversationMessageRepository
    private let announcementRepository: AnnouncementRepository
    private let missionRepository: MissionRepository
    
    init(
        userRepository: UserRepository,
        conversationRepository: ConversationRepository,
        messageRepository: MessageRepository,
        conversationMessageRepository: ConversationMessageRepository,
        announcementRepository: AnnouncementRepository,
        missionRepository: MissionRepository
    ) {
        self.userRepository = userRepository
        self.conversationRepository = conversationRepository
        self.messageRepository = messageRepository
        self.conversationMessageRepository = conversationMessageRepository
        self.announcementRepository = announcementRepository
        self.missionRepository = missionRepository
    }
    
    func execute() async {
        userRepository.deleteLocalUser()
        try? await messageRepository.deleteLocalMessages()
        try? await conversationRepository.deleteLocalConversations()
        conversationMessageRepository.deleteConversationMessage()
        try? await announcementRepository.deleteLocalAnnouncements()
        try? await missionRepository.deleteLocalMissions()
    }
}
