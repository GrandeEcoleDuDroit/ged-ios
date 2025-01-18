import Combine

class AnnouncementRepositoryImpl: AnnouncementRepository {
    private let announcementLocalDataSource: AnnouncementLocalDataSource
    private let announcementRemoteDataSource: AnnouncementRemoteDataSource
    
    var announcements: AnyPublisher<[Announcement], Never>
    
    init(
        announcementLocalDataSource: AnnouncementLocalDataSource,
        announcementRemoteDataSource: AnnouncementRemoteDataSource
    ) {
        self.announcementLocalDataSource = announcementLocalDataSource
        self.announcementRemoteDataSource = announcementRemoteDataSource
        self.announcements = announcementLocalDataSource.announcements.eraseToAnyPublisher()
    }
    
    func createAnnouncement(announcement: Announcement) async throws {
        async let localResult: Void = try await announcementLocalDataSource.insertAnnouncement(announcement: announcement)
        async let remoteResult: Void = try await announcementRemoteDataSource.createAnnouncement(announcement: announcement)
        
        try await localResult
        try await remoteResult
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        async let localResult: Void = try await announcementLocalDataSource.updateAnnouncement(announcement: announcement)
        async let remoteResult: Void = try await announcementRemoteDataSource.updateAnnouncement(announcement: announcement)
        
        try await localResult
        try await remoteResult
    }
    
    func updateAnnouncementState(announcementId: String, state: AnnouncementState) async throws {
        try await announcementLocalDataSource.updateAnnouncementState(announcementId: announcementId, state: state)
    }
    
    func deleteAnnouncement(announcement: Announcement) async throws {
        async let localResult: Void = try await announcementLocalDataSource.deleteAnnouncement(announcement: announcement)
        async let remoteResult: Void = try await announcementRemoteDataSource.deleteAnnouncement(announcementId: announcement.id)
        
        try await localResult
        try await remoteResult
    }
}
