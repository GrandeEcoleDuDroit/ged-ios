import Foundation
import Combine
import CoreData

private let announcementEntityName = "LocalAnnouncement"

class AnnouncementLocalRepositoryImpl: AnnouncementLocalRepository {
    private let gedDatabaseContainer: GedDatabaseContainer
    private let request = NSFetchRequest<LocalAnnouncement>(entityName: announcementEntityName)
    @Published private var _announcements: [Announcement] = []
    var announcements: AnyPublisher<[Announcement], Never> {
        $_announcements.eraseToAnyPublisher()
    }
    
    init(gedDatabaseContainer: GedDatabaseContainer) {
        self.gedDatabaseContainer = gedDatabaseContainer
    }
    
    private func fetchAnnouncements() {
        do {
            _announcements = try gedDatabaseContainer.container.viewContext.fetch(request).map({ localAnnouncement in
                AnnouncementMapper.toDomain(localAnnouncement: localAnnouncement)
            })
        } catch {
            print("Failed to fetch announcements: \(error)")
        }
    }
    
    func insertAnnouncement(announcement: Announcement) async throws {
        AnnouncementMapper.toLocal(announcement: announcement, context: gedDatabaseContainer.container.viewContext)
        try gedDatabaseContainer.container.viewContext.save()
    }
}
