import Combine

class GetAnnouncementsUseCase {
    private let announcementLocalRepository: AnnouncementLocalRepository
    
    init(announcementLocalRepository: AnnouncementLocalRepository) {
        self.announcementLocalRepository = announcementLocalRepository
    }
    
    func execute() -> AnyPublisher<[Announcement], Never> {
        announcementLocalRepository.announcements
    }
}
