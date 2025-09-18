import Foundation

class AnnouncementRemoteDataSource {
    private let announcementApi: AnnouncementApi
    private let tag = String(describing: AnnouncementRemoteDataSource.self)
    
    init(announcementApi: AnnouncementApi) {
        self.announcementApi = announcementApi
    }
    
    func getAnnouncements() async throws -> [Announcement] {
        try await mapServerError(
            block: { try await announcementApi.getAnnouncements() },
            tag: tag,
            message: "Failed to get remote announcements"
        ).map { $0.toAnnouncement() }
    }
    
    func createAnnouncement(announcement: Announcement) async throws {
        try await mapServerError(
            block: { try await announcementApi.createAnnouncement(remoteAnnouncement: announcement.toRemote()) },
            tag: tag,
            message: "Failed to create remote announcement"
        )
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        try await mapServerError(
            block: { try await announcementApi.updateAnnouncement(remoteAnnouncement: announcement.toRemote()) },
            tag: tag,
            message: "Failed to update remote announcement"
        )
    }
    
    func deleteAnnouncement(announcementId: String) async throws {
        try await mapServerError(
            block: { try await announcementApi.deleteAnnouncement(remoteAnnouncementId: announcementId) },
            tag: tag,
            message: "Failed to delete remote announcement"
        )
    }
    
    func reportAnnouncement(report: AnnouncementReport) async throws {
        try await mapServerError(
            block: { try await announcementApi.reportAnnouncement(report: report) },
            tag: tag,
            message: "Failed to report remote announcement"
        )
    }
}
