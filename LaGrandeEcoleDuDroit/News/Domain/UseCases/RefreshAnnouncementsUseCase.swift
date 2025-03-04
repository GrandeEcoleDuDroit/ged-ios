class RefreshAnnouncementsUseCase {
    private let announcementRepository: AnnouncementRepository
    private var taskCount = 0
    
    init(announcementRepository: AnnouncementRepository) {
        self.announcementRepository = announcementRepository
    }
    
    func execute() async {
        guard taskCount == 0 else { return }
        taskCount += 1
        await announcementRepository.refreshAnnouncements()
        taskCount -= 1
    }
}
