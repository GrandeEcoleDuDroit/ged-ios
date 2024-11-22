protocol AnnouncementRemoteRepository {
    func getAnnouncements() async throws -> [Announcement]
    
    func createAnnouncement(announcement: Announcement) async throws
    
    func updateAnnouncement(announcement: Announcement) async throws
}
