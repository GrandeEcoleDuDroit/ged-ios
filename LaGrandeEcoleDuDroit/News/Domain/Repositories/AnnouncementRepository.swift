import Combine

protocol AnnouncementRepository {
    var announcements: AnyPublisher<[Announcement], Never> { get }
    
    func createAnnouncement(announcement: Announcement) async throws

    func updateAnnouncement(announcement: Announcement) async throws
    
    func updateAnnouncementState(announcementId: String, state: AnnouncementState) async throws
    
    func deleteAnnouncement(announcement: Announcement) async throws
}
