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
    
    init(
        id: String,
        title: String,
        description: String,
        date: Date,
        startDate: Date,
        endDate: Date,
        schoolLevels: [SchoolLevel],
        duration: String?,
        managers: [User],
        participants: [User],
        maxParticipants: Int,
        tasks: [MissionTask],
        state: MissionState
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.startDate = startDate
        self.endDate = endDate
        self.schoolLevels = schoolLevels
        self.duration = duration
        self.managers = managers
        self.participants = participants
        self.maxParticipants = maxParticipants
        self.tasks = tasks
        self.state = state
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var schoolLevelRestricted: Bool {
        !schoolLevels.isEmpty &&
            schoolLevels.count < SchoolLevel.allCases.count
    }
    
    var full: Bool {
        participants.count >= maxParticipants
    }
    
    var complete: Bool {
        endDate.isAlmostBefore(to: Date())
    }
    
    func schoolLevelPermitted(schoolLevel: SchoolLevel) -> Bool {
        schoolLevels.isEmpty || schoolLevels.contains(schoolLevel)
    }
 
    enum MissionState: Hashable {
        case draft
        case publishing(imagePath: String? = nil)
        case published(imageUrl: String? = nil)
        case error(imagePath: String? = nil)

        var type: StateType {
            switch self {
                case .draft: .draftType
                case .publishing: .publishingType
                case .published: .publishedType
                case .error: .errorType
            }
        }
        
        var description: String { type.rawValue }
        
        var imageReference: String? {
            switch self {
                case .draft: nil
                case let .publishing(imagePath: path): path
                case let .published(imageUrl: url): url
                case let .error(imagePath: path): path
            }
        }
        
        enum StateType: String {
            case draftType = "DRAFT"
            case publishingType = "PUBLISHING"
            case publishedType = "PUBLISHED"
            case errorType = "ERROR"
        }
    }
}
