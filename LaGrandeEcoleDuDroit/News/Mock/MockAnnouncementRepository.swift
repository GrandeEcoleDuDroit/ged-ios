import Foundation
import Combine

class MockAnnouncementRepository: AnnouncementRepository {
    private let _announcements = CurrentValueSubject<[Announcement], Never>(announcementsFixture)
    var announcements: AnyPublisher<[Announcement], Never> {
        _announcements.eraseToAnyPublisher()
    }
    
    func createAnnouncement(announcement: Announcement) async throws {
        _announcements.value.append(announcement)
    }
    
    func updateAnnouncement(announcement: Announcement) async throws {
        _announcements.value = _announcements.value.map { $0.id == announcement.id ? announcement : $0 }
    }
    
    func updateAnnouncementState(announcementId: String, state: AnnouncementState) async throws {
        _announcements.value = _announcements.value.map({ $0.id == announcementId ? $0.with(state: state) : $0 })
    }
    
    func deleteAnnouncement(announcement: Announcement) async throws {
        _announcements.value.removeAll(where: { $0.id == announcement.id })
    }
    
    
}
