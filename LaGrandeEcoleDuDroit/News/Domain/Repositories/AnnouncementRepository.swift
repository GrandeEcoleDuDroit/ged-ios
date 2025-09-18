import Combine

protocol AnnouncementRepository {
    var announcements: AnyPublisher<[Announcement], Never> { get }
            
    func getAnnouncementPublisher(announcementId: String) -> AnyPublisher<Announcement?, Never>
        
    func refreshAnnouncements() async throws
    
    func createAnnouncement(announcement: Announcement) async throws
    
    func updateAnnouncement(announcement: Announcement) async throws
    
    func updateLocalAnnouncement(announcement: Announcement) async throws
        
    func deleteAnnouncement(announcementId: String) async throws
    
    func deleteLocalAnnouncement(announcementId: String) async throws
    
    func reportAnnouncement(report: AnnouncementReport) async throws
}
