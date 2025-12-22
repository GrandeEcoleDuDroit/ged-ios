class StartupAnnouncementTask {
    private let networkMonitor: NetworkMonitor
    private let announcementRepository: AnnouncementRepository
    private let resendAnnouncementUseCase: ResendAnnouncementUseCase
    private let tag = String(describing: StartupAnnouncementTask.self)

    init(
        networkMonitor: NetworkMonitor,
        announcementRepository: AnnouncementRepository,
        resendAnnouncementUseCase: ResendAnnouncementUseCase
    ) {
        self.networkMonitor = networkMonitor
        self.announcementRepository = announcementRepository
        self.resendAnnouncementUseCase = resendAnnouncementUseCase
    }
    
    func run() {
        Task {
            await networkMonitor.connected.values.first { $0 }
            await sendUnsentAnnouncements()
        }
    }
    
    private func sendUnsentAnnouncements() async {
        do {
            let announcements = try await announcementRepository.getLocalAnnouncements()
            for announcement in announcements {
                if case .publishing = announcement.state {
                    await resendAnnouncementUseCase.execute(announcement: announcement)
                }
            }
        } catch {
            e(tag, "Failed to send unsent announcements", error)
        }
    }
}
