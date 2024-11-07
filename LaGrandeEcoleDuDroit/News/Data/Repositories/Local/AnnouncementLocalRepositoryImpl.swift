import Foundation

class AnnouncementLocalRepositoryImpl: AnnouncementLocalRepository {
    func getAnnouncements() -> [Announcement] {
        return announcementsFixture
    }
}
