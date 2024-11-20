class DeleteAnnouncementUseCase {
    private let announcementRemoteRepository: AnnouncementRemoteRepository
    private let announcementLocalRepository: AnnouncementLocalRepository
    
    init(announcementRemoteRepository: AnnouncementRemoteRepository,
         announcementLocalRepository: AnnouncementLocalRepository
    ) {
        self.announcementRemoteRepository = announcementRemoteRepository
        self.announcementLocalRepository = announcementLocalRepository
    }
    
    func execute(announcement: Announcement) async throws {
        async let localResult: Void = try announcementLocalRepository.deleteAnnouncement(announcement: announcement)
        async let remoteResult: Void = try announcementRemoteRepository.deleteAnnouncement(announcement: announcement)
        
        try await localResult
        try await remoteResult
    }
}
