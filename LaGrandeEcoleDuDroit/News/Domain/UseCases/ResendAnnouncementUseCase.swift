class ResendAnnouncementUseCase {
    private let announcementRepository: AnnouncementRepository
    private let networkMonitor: NetworkMonitor

    init(
        announcementRepository: AnnouncementRepository,
        networkMonitor: NetworkMonitor
    ) {
        self.announcementRepository = announcementRepository
        self.networkMonitor = networkMonitor
    }
    
    func execute(announcement: Announcement) throws {
        guard networkMonitor.isConnected else {
            throw NetworkError.noInternetConnection
        }
        
        Task {
            do {
                announcementRepository.updateLocalAnnouncement(announcement: announcement.with(state: .publishing))
                try await announcementRepository.createRemoteAnnouncement(announcement: announcement)
                announcementRepository.updateLocalAnnouncement(announcement: announcement.with(state: .published))
            } catch {
                announcementRepository.updateLocalAnnouncement(announcement: announcement.with(state: .error))
            }
        }
    }
}
