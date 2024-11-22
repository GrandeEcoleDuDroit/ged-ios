class UpdateAnnouncementUseCase {
    private let announcementLocalRepository: AnnouncementLocalRepository
    private let announcementRemoteRepository: AnnouncementRemoteRepository
    
    init(announcementLocalRepository: AnnouncementLocalRepository,
         announcementRemoteRepository: AnnouncementRemoteRepository
    ) {
        self.announcementLocalRepository = announcementLocalRepository
        self.announcementRemoteRepository = announcementRemoteRepository
    }
    
    func execute(announcement: Announcement) async throws {
        async let localResult: Void = try announcementLocalRepository.updateAnnouncement(announcement: announcement)
        async let remoteResult: Void = try announcementRemoteRepository.updateAnnouncement(announcement: announcement)
        
        try await localResult
        try await remoteResult
    }
}
