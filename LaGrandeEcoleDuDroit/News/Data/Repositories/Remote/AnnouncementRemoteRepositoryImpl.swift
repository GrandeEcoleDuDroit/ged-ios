import Foundation

class AnnouncementRemoteRepositoryImpl: AnnouncementRemoteRepository {
    private let announcementApi: AnnouncementApi
    
    init(announcementApi: AnnouncementApi) {
        self.announcementApi = announcementApi
    }
    
    func getAnnouncements() async throws -> [Announcement] {
        let localAnnouncements = try await announcementApi.getAnnouncements()
        return localAnnouncements.map { AnnouncementMapper.toAnnouncement(remoteAnnouncement: $0) }
    }
}
