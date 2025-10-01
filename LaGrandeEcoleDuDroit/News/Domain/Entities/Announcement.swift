import Foundation

struct Announcement: Identifiable, Hashable, Copyable {
    var id: String
    var title: String? = nil
    var content: String
    var date: Date
    var author: User
    var state: AnnouncementState
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum AnnouncementState: String, Hashable {
    case draft = "draft"
    case publishing = "sending"
    case published = "published"
    case error = "error"
}
