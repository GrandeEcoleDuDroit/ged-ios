import Combine
import Foundation

class AnnouncementRepositoryImpl: AnnouncementRepository {
    private let tag = String(describing: AnnouncementRepositoryImpl.self)
    private let announcementLocalDataSource: AnnouncementLocalDataSource
    private let announcementRemoteDataSource: AnnouncementRemoteDataSource
    private var cancellables: Set<AnyCancellable> = []
    private var announcementsSubject = CurrentValueSubject<[Announcement], Never>([])
    var announcements: AnyPublisher<[Announcement], Never> {
        announcementsSubject.eraseToAnyPublisher()
    }
    
    init(
        announcementLocalDataSource: AnnouncementLocalDataSource,
        announcementRemoteDataSource: AnnouncementRemoteDataSource
    ) {
        self.announcementLocalDataSource = announcementLocalDataSource
        self.announcementRemoteDataSource = announcementRemoteDataSource
        loadAnnouncements()
        listenDataChanges()
    }
    
    private func listenDataChanges() {
        announcementLocalDataSource.listenDataChange()
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] _ in
                self?.loadAnnouncements()
            }.store(in: &cancellables)
    }
    
    private func loadAnnouncements() {
        Task {
            do {
                try await announcementsSubject.send(announcementLocalDataSource.getAnnouncements())
            } catch {
                e(tag, "Failed to load announcements from local data source: \(error)")
            }
        }
    }
    
    func getAnnouncementPublisher(announcementId: String) -> AnyPublisher<Announcement?, Never> {
        announcementsSubject.map { announcements in
            announcements.first { $0.id == announcementId }
        }.eraseToAnyPublisher()
    }
    
    func refreshAnnouncements() async throws {
        let remoteAnnouncements = try await mapFirebaseException(
            block: { try await announcementRemoteDataSource.getAnnouncements() },
            tag: tag,
            message: "Failed to fetch remote announcements"
        )
        
        let announcementToDelete = announcementsSubject.value
            .filter { $0.state == .published }
            .filter { !remoteAnnouncements.contains($0) }
        for announcement in announcementToDelete {
            try await announcementLocalDataSource.deleteAnnouncement(announcementId: announcement.id)
        }
        
        let announcementToUpsert = remoteAnnouncements
            .filter { !announcementsSubject.value.contains($0) }
        for announcement in announcementToUpsert {
            try await announcementLocalDataSource.upsertAnnouncement(announcement: announcement)
        }
    }
    
    
    func createAnnouncement(announcement: Announcement) async throws {
        try await announcementLocalDataSource.insertAnnouncement(announcement: announcement)
        try await mapFirebaseException(
            block: { try await announcementRemoteDataSource.createAnnouncement(announcement: announcement) },
            tag: tag,
            message: "Failed to create remote announcement"
        )
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        try await mapFirebaseException(
            block: {
                try await announcementRemoteDataSource.updateAnnouncement(announcement: announcement)
                try await announcementLocalDataSource.updateAnnouncement(announcement: announcement)
            },
            tag: tag,
            message: "Failed to update announcement"
        )
    }
    
    func updateLocalAnnouncement(announcement: Announcement) async throws {
        try await announcementLocalDataSource.updateAnnouncement(announcement: announcement)
    }
    
    func deleteAnnouncement(announcementId: String) async throws {
        try await mapFirebaseException(
            block: {
                try await announcementRemoteDataSource.deleteAnnouncement(announcementId: announcementId)
                try await announcementLocalDataSource.deleteAnnouncement(announcementId: announcementId)
            },
            tag: tag,
            message: "Failed to delete announcement"
        )
    }
    
    func deleteLocalAnnouncement(announcementId: String) async throws {
        try await announcementLocalDataSource.deleteAnnouncement(announcementId: announcementId)
    }
}
