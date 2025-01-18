import Foundation
import Combine
import CoreData
import os

private let announcementEntityName = "LocalAnnouncement"
private let tag = String(describing: AnnouncementLocalDataSource.self)

class AnnouncementLocalDataSource {
    private let request = NSFetchRequest<LocalAnnouncement>(entityName: announcementEntityName)
    private let context: NSManagedObjectContext
    
    private(set) var announcements = CurrentValueSubject<[Announcement], Never>([])
    
    init(gedDatabaseContainer: GedDatabaseContainer) {
        context = gedDatabaseContainer.container.viewContext
        fetchAnnouncements()
    }
    
    private func fetchAnnouncements() {
        do {
            let values = try context.fetch(request).map({ localAnnouncement in
                AnnouncementMapper.toDomain(localAnnouncement: localAnnouncement)
            })
            announcements.send(values)
        } catch {
            e(tag, "Failed to fetch announcements: \(error)")
        }
    }
    
    func insertAnnouncement(announcement: Announcement) async throws {
        do {
            AnnouncementMapper.toLocal(announcement: announcement, context: context)
            try context.save()
            announcements.value.append(announcement)
        } catch {
            e(tag, "Failed to insert announcement: \(error)")
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
            
            announcements.value = announcements.value.map({ $0.id == announcement.id ? announcement : $0 })
        } catch {
            e(tag, "Failed to update announcement: \(error)")
            throw error
        }
    }
    
    func updateAnnouncementState(announcementId: String, state: AnnouncementState) async throws {
        do {
            let localAnnouncement = try context.fetch(request).first(where: { $0.announcementId == announcementId })
            localAnnouncement?.announcementState = state.description
            try context.save()
            
            announcements.value = announcements.value.map({ $0.id == announcementId ? AnnouncementMapper.toDomain(localAnnouncement: localAnnouncement!) : $0 })
        } catch {
            e(tag, "Failed to update announcement state: \(error)")
            throw error
        }
    }
    
    func deleteAnnouncement(announcement: Announcement) async throws {
        let localAnnouncement = try context.fetch(request).first {
            $0.announcementId == announcement.id
        }
        if localAnnouncement != nil {
            context.delete(localAnnouncement!)
            try context.save()
        }
        announcements.value.removeAll { $0.id == announcement.id }
    }
}
