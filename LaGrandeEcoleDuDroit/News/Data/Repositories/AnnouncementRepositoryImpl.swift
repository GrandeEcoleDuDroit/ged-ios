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
    
    func getAnnouncementPublisher(announcementId: String) -> AnyPublisher<Announcement?, Never> {
        announcementsSubject.map { announcements in
            announcements.first { $0.id == announcementId }
        }.eraseToAnyPublisher()
    }
    
    func getLocalAnnouncements() async throws -> [Announcement] {
        do {
            return try await announcementLocalDataSource.getAnnouncements()
        } catch {
            e(tag, "Error getting local announcements", error)
            throw error
        }
    }
    
    func getRemoteAnnouncements() async throws -> [Announcement] {
        do {
            return try await announcementRemoteDataSource.getAnnouncements()
        } catch {
            e(tag, "Error getting remote announcements", error)
            throw error
        }
    }
    
    func createAnnouncement(announcement: Announcement) async throws {
        do {
            try await announcementLocalDataSource.upsertAnnouncement(announcement: announcement)
            try await announcementRemoteDataSource.createAnnouncement(announcement: announcement)
        } catch {
            e(tag, "Error creating announcements", error)
            throw error
        }
    }
    
    func upsertLocalAnnouncement(announcement: Announcement) async throws {
        do {
            try await announcementLocalDataSource.upsertAnnouncement(announcement: announcement)
        } catch {
            e(tag, "Error upserting local announcement \(announcement.id)", error)
            throw error
        }
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        do {
            try await announcementRemoteDataSource.updateAnnouncement(announcement: announcement)
            try await announcementLocalDataSource.updateAnnouncement(announcement: announcement)
        } catch {
            e(tag, "Error updating announcement \(announcement.id)", error)
            throw error
        }
    }
    
    func updateLocalAnnouncement(announcement: Announcement) async throws {
        do {
            try await announcementLocalDataSource.updateAnnouncement(announcement: announcement)
        } catch {
            e(tag, "Error updating local announcement \(announcement.id)", error)
            throw error
        }
    }
    
    func deleteAnnouncement(announcementId: String, authorId: String) async throws {
        do {
            try await announcementRemoteDataSource.deleteAnnouncement(announcementId: announcementId, authorId: authorId)
            try await announcementLocalDataSource.deleteAnnouncement(announcementId: announcementId)
        } catch {
            e(tag, "Error deleting announcement \(announcementId)", error)
        }
    }
    
    func deleteLocalAnnouncements() async throws {
        do {
            try await announcementLocalDataSource.deleteAnnouncements()
        } catch {
            e(tag, "Error deleting local announcements", error)
            throw error
        }
    }
    
    func deleteLocalAnnouncement(announcementId: String) async throws {
        do {
            try await announcementLocalDataSource.deleteAnnouncement(announcementId: announcementId)
        } catch {
            e(tag, "Error deleting local announcement \(announcementId)", error)
            throw error
        }
    }

    func deleteLocalUserAnnouncements(userId: String) async throws {
        do {
            try await announcementLocalDataSource.deleteAnnouncements(userId: userId)
        } catch {
            e(tag, "Error deleting local announcements of user \(userId)", error)
            throw error
        }
    }
        
    func reportAnnouncement(report: AnnouncementReport) async throws {
        do {
            try await announcementRemoteDataSource.reportAnnouncement(report: report)
        } catch {
            e(tag, "Error reporting announcement \(report.announcementId)", error)
            throw error
        }
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
}
