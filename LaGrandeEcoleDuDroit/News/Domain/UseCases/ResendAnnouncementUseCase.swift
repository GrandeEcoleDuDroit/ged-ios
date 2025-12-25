class ResendAnnouncementUseCase {
    private let announcementRepository: AnnouncementRepository
    private let announcementTaskReferences: AnnouncementTaskQueue

    init(
        announcementRepository: AnnouncementRepository,
        announcementTaskReferences: AnnouncementTaskQueue
    ) {
        self.announcementRepository = announcementRepository
        self.announcementTaskReferences = announcementTaskReferences
    }
    
    func execute(announcement: Announcement) async {
        let task = Task {
            do {
                try await announcementRepository.createAnnouncement(announcement: announcement.copy { $0.state = .publishing })
                try await announcementRepository.updateLocalAnnouncement(announcement: announcement.copy { $0.state = .published })
                await announcementTaskReferences.removeTaskReference(for: announcement.id)
            } catch {
                try? await announcementRepository.updateLocalAnnouncement(announcement: announcement.copy { $0.state = .error })
                await announcementTaskReferences.removeTaskReference(for: announcement.id)
            }
        }
        
        await announcementTaskReferences.addTaskReference(task, for: announcement.id)
    }
}
