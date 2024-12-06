import Combine

class MockAnnouncementLocalRepository: AnnouncementLocalRepository {
    @Published private var _announcements: [Announcement] = announcementsFixture
    var announcements: AnyPublisher<[Announcement], Never> {
        $_announcements.eraseToAnyPublisher()
    }
    
    func insertAnnouncement(announcement: Announcement) async throws {
        _announcements.append(announcement)
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        _announcements = _announcements.map { $0.id == announcement.id ? announcement : $0 }
    }
    
    func deleteAnnouncement(announcement: Announcement) async throws {
        _announcements.removeAll(where: { $0 == announcement })
    }
}
