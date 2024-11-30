import Foundation

struct Announcement: Hashable {
    var id: String
    var title: String? = nil
    var content: String
    var date: Date
    var author: User
    var state: AnnouncementState = .idle
    
    static func == (lhs: Announcement, rhs: Announcement) -> Bool {
        lhs.id == rhs.id
    }
}
