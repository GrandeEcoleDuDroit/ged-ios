import Foundation

struct Announcement: Hashable {
    var id: Int
    var title: String? = nil
    var content: String
    var date: Date
    var author: User
    
    static func == (lhs: Announcement, rhs: Announcement) -> Bool {
        lhs.id == rhs.id
    }
}
