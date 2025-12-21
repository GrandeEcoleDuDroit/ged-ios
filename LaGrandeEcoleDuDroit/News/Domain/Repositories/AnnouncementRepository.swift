import Combine

protocol AnnouncementRepository {
    var announcements: AnyPublisher<[Announcement], Never> { get }
    
    var currentAnnouncements: [Announcement] { get }
            
    func getAnnouncementPublisher(announcementId: String) -> AnyPublisher<Announcement?, Never>
    
    func getRemoteAnnouncements() async throws -> [Announcement]
        
    func createAnnouncement(announcement: Announcement) async throws
    
    func upsertLocalAnnouncement(announcement: Announcement) async throws
    
    func updateAnnouncement(announcement: Announcement) async throws
    
    func updateLocalAnnouncement(announcement: Announcement) async throws
    
    func deleteAnnouncements(userId: String) async throws
        
    func deleteAnnouncement(announcementId: String, authorId: String) async throws
    
    func deleteLocalAnnouncement(announcementId: String) async throws
    
    func deleteLocalAnnouncements() async throws
        
    func deleteLocalAnnouncements(userId: String) async throws
    
    func reportAnnouncement(report: AnnouncementReport) async throws
}
