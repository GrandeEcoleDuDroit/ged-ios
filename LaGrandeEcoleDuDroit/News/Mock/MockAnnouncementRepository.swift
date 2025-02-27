import Foundation
import Combine

class MockAnnouncementRepository: AnnouncementRepository {
    var announcements = CurrentValueSubject<[Announcement], Never>(announcementsFixture)
    
    func createAnnouncement(announcement: Announcement) async throws {
        announcements.value.append(announcement)
    }
    
    func createRemoteAnnouncement(announcement: Announcement) async throws {
        announcements.value.append(announcement)
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        announcements.value = announcements.value.map { $0.id == announcement.id ? announcement : $0 }
    }
    
    func updateAnnouncementState(announcementId: String, state: AnnouncementState) async {
        announcements.value = announcements.value.map({ $0.id == announcementId ? $0.with(state: state) : $0 })
    }
    
    func deleteAnnouncement(announcementId: String) async throws {
        announcements.value.removeAll(where: { $0.id == announcementId })
    }
    
    func deleteLocalAnnouncement(announcementId: String) async {
        announcements.value.removeAll(where: { $0.id == announcementId })
    }
}
