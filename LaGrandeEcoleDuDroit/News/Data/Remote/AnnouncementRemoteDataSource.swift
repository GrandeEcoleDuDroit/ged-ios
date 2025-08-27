import Foundation

class AnnouncementRemoteDataSource {
    private let announcementApi: AnnouncementApi
    
    init(announcementApi: AnnouncementApi) {
        self.announcementApi = announcementApi
    }
    
    func getAnnouncements() async throws -> [Announcement] {
        try await handleServerError(
            block: { try await announcementApi.getAnnouncements() }
        ).map { $0.toAnnouncement() }
    }
    
    func createAnnouncement(announcement: Announcement) async throws {
        try await mapServerError(
            block: { try await announcementApi.createAnnouncement(remoteAnnouncement: announcement.toRemote()) }
        )
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        try await mapServerError(
            block: { try await announcementApi.updateAnnouncement(remoteAnnouncement: announcement.toRemote()) }
        )
    }
    
    func deleteAnnouncement(announcementId: String) async throws {
        try await mapServerError(
            block: { try await announcementApi.deleteAnnouncement(remoteAnnouncementId: announcementId) }
        )
    }
}
