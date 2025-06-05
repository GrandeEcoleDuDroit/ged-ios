import Foundation

struct Announcement: Identifiable, Hashable {
    var id: String
    var title: String? = nil
    var content: String
    var date: Date
    var author: User
    var state: AnnouncementState
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func with(
        id: String? = nil,
        title: String? = nil,
        content: String? = nil,
        date: Date? = nil,
        author: User? = nil,
        state: AnnouncementState? = nil
    ) -> Announcement {
        Announcement(
            id: id ?? self.id,
            title: title ?? self.title,
            content: content ?? self.content,
            date: date ?? self.date,
            author: author ?? self.author,
            state: state ?? self.state
        )
    }
}

enum AnnouncementState: String, Hashable {
    case publishing = "sending"
    case published = "published"
    case error = "error"
}
