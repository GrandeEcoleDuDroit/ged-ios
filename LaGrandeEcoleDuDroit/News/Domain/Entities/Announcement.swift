import Foundation

struct Announcement {
    var id: Int
    var title: String? = nil
    var content: String
    var date: Date
    var author: User
}
