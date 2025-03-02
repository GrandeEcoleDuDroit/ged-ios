import Combine

protocol AnnouncementRepository {
    var announcements: CurrentValueSubject<[Announcement], Never> { get }
        
    func createAnnouncement(announcement: Announcement) async throws
    
    func createRemoteAnnouncement(announcement: Announcement) async throws
    
    func updateAnnouncement(announcement: Announcement) async throws
    
    func updateAnnouncementState(announcementId: String, state: AnnouncementState) async
    
    func deleteAnnouncement(announcementId: String) async throws
    
    func deleteLocalAnnouncement(announcementId: String) async
    
    func refreshAnnouncements() async throws
}
