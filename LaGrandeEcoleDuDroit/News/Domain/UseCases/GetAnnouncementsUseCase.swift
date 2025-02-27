import Combine

class GetAnnouncementsUseCase {
    private let announcementRepository: AnnouncementRepository
    
    init(announcementRepository: AnnouncementRepository) {
        self.announcementRepository = announcementRepository
    }
    
    func execute() -> CurrentValueSubject<[Announcement], Never> {
        announcementRepository.announcements
    }
}
