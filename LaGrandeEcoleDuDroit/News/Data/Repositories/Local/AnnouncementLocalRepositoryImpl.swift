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
            let localAnnouncement = try context.fetch(request).first(where: { $0.announcementId == announcement.id })
            localAnnouncement?.announcementTitle = announcement.title
            localAnnouncement?.announcementContent = announcement.content
            localAnnouncement?.announcementDate = Int32(announcement.date.timeIntervalSince1970)
            localAnnouncement?.announcementState = announcement.state.description
            localAnnouncement?.userId = announcement.author.id
            localAnnouncement?.userFirstName = announcement.author.firstName
            localAnnouncement?.userLastName = announcement.author.lastName
            localAnnouncement?.userEmail = announcement.author.email
            localAnnouncement?.userSchoolLevel = announcement.author.schoolLevel
            localAnnouncement?.userIsMember = announcement.author.isMember
            localAnnouncement?.userProfilePictureUrl = announcement.author.profilePictureUrl
            try context.save()
            _announcements = _announcements.map({ $0.id == announcement.id ? announcement : $0 })
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
}
