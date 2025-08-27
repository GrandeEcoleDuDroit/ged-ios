class DeleteAnnouncementUseCase {
    private let announcementRepository: AnnouncementRepository
    private let networkMonitor: NetworkMonitor
    
    init(
        announcementRepository: AnnouncementRepository,
        networkMonitor: NetworkMonitor
    ) {
        self.announcementRepository = announcementRepository
        self.networkMonitor = networkMonitor
    }
    
    func execute(announcement: Announcement) async throws {
        guard networkMonitor.isConnected else {
            throw NetworkError.noInternetConnection
        }
        
        if case announcement.state = .published {
            try await announcementRepository.deleteAnnouncement(announcementId: announcement.id)
        } else {
            try await announcementRepository.deleteLocalAnnouncement(announcementId: announcement.id)
        }
    }
}
