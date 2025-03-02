import Combine

class GetAnnouncementUseCase {
    private let announcementRepository: AnnouncementRepository

    init(announcementRepository: AnnouncementRepository) {
        self.announcementRepository = announcementRepository
    }

    func execute(announcementId: String) -> AnyPublisher<Announcement, Never> {
        announcementRepository.announcements.compactMap { announcements in
            announcements.first { $0.id == announcementId }
        }.eraseToAnyPublisher()
    }
}
