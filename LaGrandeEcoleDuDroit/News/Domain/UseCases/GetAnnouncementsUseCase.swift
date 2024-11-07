class GetAnnouncementsUseCase {
    private let announcementLocalRepository: AnnouncementLocalRepository
    
    init(announcementLocalRepository: AnnouncementLocalRepository) {
        self.announcementLocalRepository = announcementLocalRepository
    }
    
    func execute() -> [Announcement] {
        announcementLocalRepository.getAnnouncements()
    }
}
