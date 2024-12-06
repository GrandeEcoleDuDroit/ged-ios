class MockAnnouncementRemoteRepository: AnnouncementRemoteRepository {
    private var announcements: [Announcement] = []
    
    func getAnnouncements() async throws -> [Announcement] {
        announcements
    }
    
    func createAnnouncement(announcement: Announcement) async throws {
        announcements.append(announcement)
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        announcements = announcements.map { $0.id == announcement.id ? announcement : $0 }
    }
    
    func deleteAnnouncement(announcementId: String) async throws {
        announcements.removeAll { $0.id == announcementId }
    }
}
