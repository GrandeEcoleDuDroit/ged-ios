import Combine
import Foundation

private let tag = String(describing: AnnouncementRepositoryImpl.self)

class AnnouncementRepositoryImpl: AnnouncementRepository {
    private let announcementLocalDataSource: AnnouncementLocalDataSource
    private let announcementRemoteDataSource: AnnouncementRemoteDataSource
    private var cancellables: Set<AnyCancellable> = []
    private var announcementsPublisher = CurrentValueSubject<[Announcement], Never>([])
    var announcements: AnyPublisher<[Announcement], Never> {
        announcementsPublisher.eraseToAnyPublisher()
    }
    
    init(
        announcementLocalDataSource: AnnouncementLocalDataSource,
        announcementRemoteDataSource: AnnouncementRemoteDataSource
    ) {
        self.announcementLocalDataSource = announcementLocalDataSource
        self.announcementRemoteDataSource = announcementRemoteDataSource
        getLocalAnnouncements()
        listen()
    }
    
    private func listen() {
        announcementLocalDataSource.listenDataChange()
            .sink { [weak self] _ in
                self?.getLocalAnnouncements()
            }.store(in: &cancellables)
    }
    
    private func getLocalAnnouncements() {
        announcementsPublisher.send(announcementLocalDataSource.getAnnouncements())
    }
    
    func getAnnouncement(announcementId: String) -> Announcement? {
        announcementsPublisher.value.first { $0.id == announcementId }
    }
    
    func getAnnouncementPublisher(announcementId: String) -> AnyPublisher<Announcement?, Never> {
        announcementsPublisher.map {
            $0.first { $0.id == announcementId }
        }.eraseToAnyPublisher()
    }
    
    func refreshAnnouncements() async throws {
        let remoteAnnouncements = try await handleNetworkException(
            block: { try await announcementRemoteDataSource.getAnnouncements() },
            tag: tag,
            message: "Failed to fetch remote announcements"
        )
        
        let announcementToDelete = announcementsPublisher.value
            .filter { $0.state == .published }
            .filter { !remoteAnnouncements.contains($0) }
        announcementToDelete.forEach {
            announcementLocalDataSource.deleteAnnouncement(announcementId: $0.id)
        }
        
        let announcementToUpsert = remoteAnnouncements
            .filter { !announcementsPublisher.value.contains($0) }
        announcementToUpsert.forEach {
            announcementLocalDataSource.upsertAnnouncement(announcement: $0)
        }
    }
    
    func createLocalAnnouncement(announcement: Announcement) {
        announcementLocalDataSource.insertAnnouncement(announcement: announcement)
    }
    
    func createRemoteAnnouncement(announcement: Announcement) async throws {
        try await handleNetworkException(
            block: { try await announcementRemoteDataSource.createAnnouncement(announcement: announcement) },
            tag: tag,
            message: "Failed to create remote announcement"
        )
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        try await handleNetworkException(
            block: {
                try await announcementRemoteDataSource.updateAnnouncement(announcement: announcement)
                announcementLocalDataSource.updateAnnouncement(announcement: announcement)
            },
            tag: tag,
            message: "Failed to update announcement"
        )
    }
    
    func updateLocalAnnouncement(announcement: Announcement) {
        announcementLocalDataSource.updateAnnouncement(announcement: announcement)
    }
    
    func deleteAnnouncement(announcementId: String) async throws {
        try await handleNetworkException(
            block: {
                try await announcementRemoteDataSource.deleteAnnouncement(announcementId: announcementId)
                announcementLocalDataSource.deleteAnnouncement(announcementId: announcementId)
            },
            tag: tag,
            message: "Failed to delete announcement"
        )
    }
    
    func deleteLocalAnnouncement(announcementId: String) {
        announcementLocalDataSource.deleteAnnouncement(announcementId: announcementId)
    }
}
