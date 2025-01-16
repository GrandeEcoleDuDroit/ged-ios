import Foundation
import Combine

class MockAnnouncementRepository: AnnouncementRepository {
    @Published private var _announcements: [Announcement] = announcementsFixture
    
    var announcements: AnyPublisher<[Announcement], Never> {
        $_announcements.eraseToAnyPublisher()
    }
    
    func createAnnouncement(announcement: Announcement) async throws {
        _announcements.append(announcement)
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        _announcements = _announcements.map { $0.id == announcement.id ? announcement : $0 }
    }
    
    func deleteAnnouncement(announcement: Announcement) async throws {
        _announcements.removeAll(where: { $0.id == announcement.id })
    }
    
    
}
