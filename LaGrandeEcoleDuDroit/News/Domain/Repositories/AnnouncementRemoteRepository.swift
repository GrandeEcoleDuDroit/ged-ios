protocol AnnouncementRemoteRepository {
    func getAnnouncements() async throws -> [Announcement]
    
    func createAnnouncement(announcement: Announcement) async throws
    
    func deleteAnnouncement(announcementId: String) async throws
}
