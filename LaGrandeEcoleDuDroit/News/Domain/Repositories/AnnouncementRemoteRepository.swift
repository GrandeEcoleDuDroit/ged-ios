protocol AnnouncementRemoteRepository {
    func getAnnouncements() async throws -> [Announcement]
}
