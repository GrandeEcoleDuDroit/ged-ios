class RecreateAnnouncementUseCase {
    private let announcementRepository: AnnouncementRepository
    private let announcementTaskQueue: AnnouncementTaskQueue

    init(
        announcementRepository: AnnouncementRepository,
        announcementTaskQueue: AnnouncementTaskQueue
    ) {
        self.announcementRepository = announcementRepository
        self.announcementTaskQueue = announcementTaskQueue
    }
    
    func execute(announcement: Announcement) async {
        let task = Task {
            do {
                try await announcementRepository.createAnnouncement(announcement: announcement.copy { $0.state = .publishing })
                try await announcementRepository.updateLocalAnnouncement(announcement: announcement.copy { $0.state = .published })
                await announcementTaskQueue.removeTaskReference(for: announcement.id)
            } catch {
                try? await announcementRepository.updateLocalAnnouncement(announcement: announcement.copy { $0.state = .error })
                await announcementTaskQueue.removeTaskReference(for: announcement.id)
            }
        }
        
        await announcementTaskQueue.addTaskReference(task, for: announcement.id)
    }
}
