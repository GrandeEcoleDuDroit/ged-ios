import Foundation
import Combine

class MockAnnouncementRepository: AnnouncementRepository {
    private var announcementsPublisher = CurrentValueSubject<[Announcement], Never>(announcementsFixture)
    var announcements: AnyPublisher<[Announcement], Never> {
        announcementsPublisher.eraseToAnyPublisher()
    }
        
    func getAnnouncement(announcementId: String) -> Announcement? {
        announcementsPublisher.value.first { $0.id == announcementId }
    }
    
    func getAnnouncementPublisher(announcementId: String) -> AnyPublisher<Announcement?, Never> {
        announcementsPublisher.map { $0.first { $0.id == announcementId } }.eraseToAnyPublisher()
    }
    
    func createLocalAnnouncement(announcement: Announcement) {
        announcementsPublisher.value.append(announcement)
    }
    
    func createRemoteAnnouncement(announcement: Announcement) async throws {
        announcementsPublisher.value.append(announcement)
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        announcementsPublisher.value =
            announcementsPublisher.value.map { $0.id == announcement.id ? announcement : $0 }
    }
    
    func updateLocalAnnouncement(announcement: Announcement) {
        announcementsPublisher.value = announcementsPublisher.value.map { $0.id == announcement.id ? announcement : $0 }
    }
    
    func deleteAnnouncement(announcementId: String) async throws {
        announcementsPublisher.value.removeAll(where: { $0.id == announcementId })
    }
    
    func deleteLocalAnnouncement(announcementId: String) {
        announcementsPublisher.value.removeAll(where: { $0.id == announcementId })
    }
    
    func refreshAnnouncements() async {
        announcementsPublisher.value = announcementsFixture
    }
}
