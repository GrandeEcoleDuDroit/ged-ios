import Foundation
import Combine

class MockAnnouncementRepository: AnnouncementRepository {
    var announcements: AnyPublisher<[Announcement], Never> {
        Empty().eraseToAnyPublisher()
    }
    
    var currentAnnouncements: [Announcement] { [] }
        
    func getAnnouncement(announcementId: String) -> Announcement? { nil }
    
    func getAnnouncementPublisher(announcementId: String) -> AnyPublisher<Announcement?, Never> {
        Empty().eraseToAnyPublisher()
    }
    
    func getLocalAnnouncements(authorId: String) async throws -> [Announcement] { [] }
    
    func getRemoteAnnouncements() async throws -> [Announcement] { [] }

    func createAnnouncement(announcement: Announcement) async throws {}
    
    func createRemoteAnnouncement(announcement: Announcement) async throws {}
    
    func upsertLocalAnnouncement(announcement: Announcement) async throws {}
    
    func updateAnnouncement(announcement: Announcement) async throws {}
    
    func updateLocalAnnouncement(announcement: Announcement) {}
    
    func deleteAnnouncements(userId: String) async throws {}
    
    func deleteAnnouncement(announcementId: String, authorId: String) async throws {}
    
    func deleteLocalAnnouncements() async throws {}
    
    func deleteLocalAnnouncements(userId: String) async throws {}
    
    func deleteLocalAnnouncement(announcementId: String) {}
            
    func reportAnnouncement(report: AnnouncementReport) async throws {}
}
