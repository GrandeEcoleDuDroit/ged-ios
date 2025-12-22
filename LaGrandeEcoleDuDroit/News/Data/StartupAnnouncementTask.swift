class StartupAnnouncementTask {
    private let networkMonitor: NetworkMonitor
    private let userRepository: UserRepository
    private let announcementRepository: AnnouncementRepository
    private let tag = String(describing: StartupAnnouncementTask.self)

    init(
        networkMonitor: NetworkMonitor,
        userRepository: UserRepository,
        announcementRepository: AnnouncementRepository
    ) {
        self.networkMonitor = networkMonitor
        self.userRepository = userRepository
        self.announcementRepository = announcementRepository
    }
    
    func run() {
        Task {
            await networkMonitor.connected.values.first { $0 }
            await sendUnsentAnnouncements()
        }
    }
    
    private func sendUnsentAnnouncements() async {
        do {
            guard let userId = self.userRepository.currentUser?.id else { return }
            let announcements = try await announcementRepository.getLocalAnnouncements(authorId: userId)
            
            for announcement in announcements {
                if case .publishing = announcement.state {
                    try await self.announcementRepository.createRemoteAnnouncement(announcement: announcement)
                }
            }
        } catch {
            e(tag, "Failed to send unsent announcements", error)
        }
    }
}
