import Foundation
import Combine
import CoreData
import os

class AnnouncementLocalDataSource {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    private let announcementActor :AnnouncementCoreDataActor
    
    init(gedDatabaseContainer: GedDatabaseContainer) {
        container = gedDatabaseContainer.container
        context = container.newBackgroundContext()
        announcementActor = AnnouncementCoreDataActor(context: context)
    }
    
    func listenDataChange() -> AnyPublisher<Notification, Never> {
        NotificationCenter.default.publisher(
            for: .NSManagedObjectContextDidSave,
            object: context
        )
        .eraseToAnyPublisher()
    }
    
    func getAnnouncements() async throws -> [Announcement] {
        try await announcementActor.getAnnouncements()
    }
    
    func upsertAnnouncement(announcement: Announcement) async throws {
        try await announcementActor.upsert(announcement: announcement)
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        try await announcementActor.update(announcement: announcement)
    }
    
    func deleteAnnouncement(announcementId: String) async throws {
        try await announcementActor.delete(announcementId: announcementId)
    }
    
    func deleteUserAnnouncements(userId: String) async throws {
        try await announcementActor.deleteUserAnnouncements(userId: userId)
    }
}
