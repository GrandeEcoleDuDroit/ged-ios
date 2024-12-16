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
        let remoteAnnouncement = AnnouncementMapper.toRemote(announcement: announcement)
        try await announcementApi.createAnnouncement(remoteAnnouncement: remoteAnnouncement)
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        let remoteAnnouncement = AnnouncementMapper.toRemote(announcement: announcement)
        try await announcementApi.updateAnnouncement(remoteAnnouncement: remoteAnnouncement)
    }
    
    func deleteAnnouncement(announcementId: String) async throws {
        try await announcementApi.deleteAnnouncement(remoteAnnouncementId: announcementId)
    }
}
