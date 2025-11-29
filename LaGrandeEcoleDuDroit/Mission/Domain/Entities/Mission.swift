import Foundation

struct Mission: Copyable, Identifiable, Hashable {
    var id: String
    var title: String
    var description: String
    var date: Date
    var startDate: Date
    var endDate: Date
    var schoolLevels: [SchoolLevel]
    var duration: String?
    var managers: [User]
    var participants: [User]
    var maxParticipants: Int
    var tasks: [MissionTask]
    var state: MissionState
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var schoolLevelRestricted: Bool {
        !schoolLevels.isEmpty &&
            schoolLevels.count < SchoolLevel.allCases.count
    }
 
    enum MissionState: Hashable {
        case draft
        case publishing(imagePath: String? = nil)
        case published(imageUrl: String? = nil)
        case error(imagePath: String? = nil)

        enum MissionStateType: String {
            case draft = "DRAFT"
            case publishing = "PUBLISHING"
            case published = "PUBLISHED"
            case error = "ERROR"
        }

        var type: MissionStateType {
            switch self {
                case .draft: .draft
                case .publishing: .publishing
                case .published: .published
                case .error: .error
            }
        }

        var description: String { type.rawValue }
    }
}
