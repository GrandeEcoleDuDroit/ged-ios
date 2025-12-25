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
    var currentAnnouncements: [Announcement] {
        announcementsSubject.value
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
            .sink { [weak self] _ in
                self?.loadAnnouncements()
            }.store(in: &cancellables)
    }
    
    private func loadAnnouncements() {
        Task {
            if let announcements = try? await announcementLocalDataSource.getAnnouncements() {
                announcementsSubject.send(announcements)
            }
        }
    }
    
    func getAnnouncementPublisher(announcementId: String) -> AnyPublisher<Announcement?, Never> {
        announcementsSubject.map { announcements in
            announcements.first { $0.id == announcementId }
        }.eraseToAnyPublisher()
    }
    
    func getLocalAnnouncements() async throws -> [Announcement] {
        try await announcementLocalDataSource.getAnnouncements()
    }
    
    func getRemoteAnnouncements() async throws -> [Announcement] {
        try await announcementRemoteDataSource.getAnnouncements()
    }
    
    func createAnnouncement(announcement: Announcement) async throws {
        try await announcementLocalDataSource.upsertAnnouncement(announcement: announcement)
        try await announcementRemoteDataSource.createAnnouncement(announcement: announcement)
    }
    
    func upsertLocalAnnouncement(announcement: Announcement) async throws {
        try await announcementLocalDataSource.upsertAnnouncement(announcement: announcement)
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        try await announcementRemoteDataSource.updateAnnouncement(announcement: announcement)
        try await announcementLocalDataSource.updateAnnouncement(announcement: announcement)
    }
    
    func updateLocalAnnouncement(announcement: Announcement) async throws {
        try await announcementLocalDataSource.updateAnnouncement(announcement: announcement)
    }
    
    func deleteAnnouncement(announcementId: String, authorId: String) async throws {
        try await announcementRemoteDataSource.deleteAnnouncement(announcementId: announcementId, authorId: authorId)
        try await announcementLocalDataSource.deleteAnnouncement(announcementId: announcementId)
    }
    
    func deleteLocalAnnouncement(announcementId: String) async throws {
        try await announcementLocalDataSource.deleteAnnouncement(announcementId: announcementId)
    }

    func deleteLocalAnnouncements() async throws {
        try await announcementLocalDataSource.deleteAnnouncements()
    }
    
    func deleteLocalAnnouncements(userId: String) async throws {
        try await announcementLocalDataSource.deleteAnnouncements(userId: userId)
    }
        
    func reportAnnouncement(report: AnnouncementReport) async throws {
        try await announcementRemoteDataSource.reportAnnouncement(report: report)
    }
}
