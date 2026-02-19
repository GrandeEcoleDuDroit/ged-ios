import Foundation

class AnnouncementRemoteDataSource {
    private let announcementApi: AnnouncementApi
    private let tag = String(describing: AnnouncementRemoteDataSource.self)
    
    init(announcementApi: AnnouncementApi) {
        self.announcementApi = announcementApi
    }
    
    func getAnnouncements() async throws -> [Announcement] {
        return try await announcementApi.getAnnouncements().map { $0.toAnnouncement() }
    }
    
    func createAnnouncement(announcement: Announcement) async throws {
        try await announcementApi.createAnnouncement(remoteAnnouncement: announcement.toRemote())
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        try await announcementApi.updateAnnouncement(remoteAnnouncement: announcement.toRemote())
    }
    
    func deleteAnnouncement(announcementId: String, authorId: String) async throws {
        try await announcementApi.deleteAnnouncement(announcementId: announcementId, authorId: authorId)
    }
    
    func reportAnnouncement(report: AnnouncementReport) async throws {
        try await announcementApi.reportAnnouncement(report: report.toRemote())
    }
}
