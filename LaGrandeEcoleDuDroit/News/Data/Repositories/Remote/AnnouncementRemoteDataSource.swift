import Foundation

class AnnouncementRemoteDataSource {
    private let announcementApi: AnnouncementApi
    
    init(announcementApi: AnnouncementApi) {
        self.announcementApi = announcementApi
    }
    
    func getAnnouncements() async throws -> [Announcement] {
        let localAnnouncements = try await announcementApi.getAnnouncements()
        return localAnnouncements.map { AnnouncementMapper.toDomain(remoteAnnouncementWithUser: $0) }
    }
    
    func createAnnouncement(announcement: Announcement) async throws {
        try await announcementApi.createAnnouncement(remoteAnnouncement: AnnouncementMapper.toRemote(announcement: announcement))
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        try await announcementApi.updateAnnouncement(remoteAnnouncement: AnnouncementMapper.toRemote(announcement: announcement))
    }
    
    func deleteAnnouncement(announcementId: String) async throws {
        try await announcementApi.deleteAnnouncement(remoteAnnouncementId: announcementId)
    }
}
