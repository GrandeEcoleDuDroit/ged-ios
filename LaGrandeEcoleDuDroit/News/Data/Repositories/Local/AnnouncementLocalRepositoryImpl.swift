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
    private let context: NSManagedObjectContext
    
    init(gedDatabaseContainer: GedDatabaseContainer) {
        self.gedDatabaseContainer = gedDatabaseContainer
        context = gedDatabaseContainer.container.viewContext
        fetchAnnouncements()
    }
    
    private func fetchAnnouncements() {
        do {
            _announcements = try context.fetch(request).map({ localAnnouncement in
                AnnouncementMapper.toDomain(localAnnouncement: localAnnouncement)
            })
        } catch {
            print("Failed to fetch announcements: \(error)")
        }
    }
    
    func insertAnnouncement(announcement: Announcement) async throws {
        do {
            AnnouncementMapper.toLocal(announcement: announcement, context: context)
            try context.save()
            _announcements.append(announcement)
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        do {
            
            _announcements.append(announcement)
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
    func deleteAnnouncement(announcement: Announcement) async throws {
        let localAnnouncement = AnnouncementMapper.toLocal(announcement: announcement, context: gedDatabaseContainer.container.viewContext)
        gedDatabaseContainer.container.viewContext.delete()
    }
}
