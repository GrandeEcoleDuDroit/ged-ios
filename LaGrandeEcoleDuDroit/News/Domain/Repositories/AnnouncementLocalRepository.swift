import Combine

protocol AnnouncementLocalRepository {
    var announcements: AnyPublisher<[Announcement], Never> { get }
    
    func insertAnnouncement(announcement: Announcement) async throws
    
    func updateAnnouncement(announcement: Announcement) async throws
    
    func deleteAnnouncement(announcement: Announcement) async throws
}
