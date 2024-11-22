protocol AnnouncementApi {
    func getAnnouncements() async throws -> [RemoteAnnouncementWithUser]
    
    func createAnnouncement(remoteAnnouncement: RemoteAnnouncement) async throws
    
    func updateAnnouncement(remoteAnnouncement: RemoteAnnouncement) async throws
}
