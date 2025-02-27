import Combine

class AnnouncementRepositoryImpl: AnnouncementRepository {
    private let announcementLocalDataSource: AnnouncementLocalDataSource
    private let announcementRemoteDataSource: AnnouncementRemoteDataSource
    
    var announcements = CurrentValueSubject<[Announcement], Never>([])
    
    init(
        announcementLocalDataSource: AnnouncementLocalDataSource,
        announcementRemoteDataSource: AnnouncementRemoteDataSource
    ) {
        self.announcementLocalDataSource = announcementLocalDataSource
        self.announcementRemoteDataSource = announcementRemoteDataSource
        self.announcements = announcementLocalDataSource.announcements
    }
    
    func createAnnouncement(announcement: Announcement) async throws {
        async let localResult: Void = try await announcementLocalDataSource.insertAnnouncement(announcement: announcement)
        async let remoteResult: Void = try await announcementRemoteDataSource.createAnnouncement(announcement: announcement)
        
        try await localResult
        try await remoteResult
    }
    
    func createRemoteAnnouncement(announcement: Announcement) async throws {
        try await announcementRemoteDataSource.createAnnouncement(announcement: announcement)
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        try await announcementRemoteDataSource.updateAnnouncement(announcement: announcement)
        try await announcementLocalDataSource.updateAnnouncement(announcement: announcement)
    }
    
    func updateAnnouncementState(announcementId: String, state: AnnouncementState) async {
        try? await announcementLocalDataSource.updateAnnouncementState(announcementId: announcementId, state: state)
    }
    
    func deleteAnnouncement(announcementId: String) async throws {
        try await announcementRemoteDataSource.deleteAnnouncement(announcementId: announcementId)
        try await announcementLocalDataSource.deleteAnnouncement(announcementId: announcementId)
    }
    
    func deleteLocalAnnouncement(announcementId: String) async {
        try? await announcementLocalDataSource.deleteAnnouncement(announcementId: announcementId)
    }
}
