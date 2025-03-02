import Combine
import Foundation

private let tag = String(describing: AnnouncementRepositoryImpl.self)

class AnnouncementRepositoryImpl: AnnouncementRepository {
    private let announcementLocalDataSource: AnnouncementLocalDataSource
    private let announcementRemoteDataSource: AnnouncementRemoteDataSource
    
    var announcements = CurrentValueSubject<[Announcement], Never>([])
    private var refreshTaskCount = 0
    
    init(
        announcementLocalDataSource: AnnouncementLocalDataSource,
        announcementRemoteDataSource: AnnouncementRemoteDataSource
    ) {
        self.announcementLocalDataSource = announcementLocalDataSource
        self.announcementRemoteDataSource = announcementRemoteDataSource
        self.announcements = announcementLocalDataSource.announcements
    }
    
    func createAnnouncement(announcement: Announcement) async throws {
        do {
            async let localResult: Void = try await announcementLocalDataSource.insertAnnouncement(announcement: announcement)
            async let remoteResult: Void = try await announcementRemoteDataSource.createAnnouncement(announcement: announcement)
            
            try await localResult
            try await remoteResult
        } catch {
            e(tag, error.localizedDescription, error)
            throw error
        }
    }
    
    func createRemoteAnnouncement(announcement: Announcement) async throws {
        try await announcementRemoteDataSource.createAnnouncement(announcement: announcement)
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        do {
            try await announcementRemoteDataSource.updateAnnouncement(announcement: announcement)
            try await announcementLocalDataSource.updateAnnouncement(announcement: announcement)
        } catch {
            e(tag, error.localizedDescription, error)
            throw error
        }
    }
    
    func updateAnnouncementState(announcementId: String, state: AnnouncementState) async {
        try? await announcementLocalDataSource.updateAnnouncementState(announcementId: announcementId, state: state)
    }
    
    func deleteAnnouncement(announcementId: String) async throws {
        do {
            try await announcementRemoteDataSource.deleteAnnouncement(announcementId: announcementId)
            try await announcementLocalDataSource.deleteAnnouncement(announcementId: announcementId)
        } catch {
            e(tag, error.localizedDescription, error)
            throw error
        }
    }
    
    func deleteLocalAnnouncement(announcementId: String) async {
        try? await announcementLocalDataSource.deleteAnnouncement(announcementId: announcementId)
    }
    
    func refreshAnnouncements() async throws {
        guard refreshTaskCount < 1 else { return }
        
        refreshTaskCount += 1
        let remoteAnnouncements = try await announcementRemoteDataSource.getAnnouncements()
        
        let announcementToDelete = announcements.value
            .filter { $0.state == .published }
            .filter { announcement in
                !remoteAnnouncements.contains { $0 == announcement }
            }
        await withTaskGroup(of: Void.self) { group in
            announcementToDelete.forEach { announcement in
                group.addTask {
                    try? await self.announcementLocalDataSource.deleteAnnouncement(announcementId: announcement.id)
                }
            }
        }
        let announcementToUpsert = remoteAnnouncements.filter { announcement in
            !announcements.value.contains { $0 == announcement }
        }
        await withTaskGroup(of: Void.self) { group in
            announcementToUpsert.forEach { announcement in
                group.addTask {
                    try? await self.announcementLocalDataSource.upsertAnnouncement(announcement: announcement)
                }
            }
        }
        
        refreshTaskCount -= 1
    }
}
