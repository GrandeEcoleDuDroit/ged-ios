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
            guard let announcements = try? await announcementLocalDataSource.getAnnouncements() else {
                return
            }
            announcementsSubject.send(announcements)
        }
    }
    
    func getAnnouncementPublisher(announcementId: String) -> AnyPublisher<Announcement?, Never> {
        announcementsSubject.map { announcements in
            announcements.first { $0.id == announcementId }
        }.eraseToAnyPublisher()
    }
    
    func refreshAnnouncements() async throws {
        let remoteAnnouncements = try await announcementRemoteDataSource.getAnnouncements()
        
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
        try await announcementLocalDataSource.upsertAnnouncement(announcement: announcement)
        try await announcementRemoteDataSource.createAnnouncement(announcement: announcement)
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        try await announcementRemoteDataSource.updateAnnouncement(announcement: announcement)
        try await announcementLocalDataSource.updateAnnouncement(announcement: announcement)
    }
    
    func updateLocalAnnouncement(announcement: Announcement) async throws {
        try await announcementLocalDataSource.updateAnnouncement(announcement: announcement)
    }
    
    func deleteAnnouncement(announcementId: String) async throws {
        try await announcementRemoteDataSource.deleteAnnouncement(announcementId: announcementId)
        try await announcementLocalDataSource.deleteAnnouncement(announcementId: announcementId)
    }
    
    func deleteLocalAnnouncement(announcementId: String) async throws {
        try await announcementLocalDataSource.deleteAnnouncement(announcementId: announcementId)
    }
    
    func reportAnnouncement(report: AnnouncementReport) async throws {
        try await announcementRemoteDataSource.reportAnnouncement(report: report)
    }
}
