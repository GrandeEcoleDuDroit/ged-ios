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
    
    func copy(
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
