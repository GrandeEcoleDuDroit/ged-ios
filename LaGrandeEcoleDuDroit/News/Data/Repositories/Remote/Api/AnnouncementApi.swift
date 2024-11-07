protocol AnnouncementApi {
    func getAnnouncements() async throws -> [RemoteAnnouncement]
}
