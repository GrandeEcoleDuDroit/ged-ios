enum SchoolLevel: Int, Identifiable, Codable, CustomStringConvertible, Equatable, Comparable {
    case level1 = 1
    case level2 = 2
    case level3 = 3
    case level4 = 4
    case unknown = 0
    
    var description: String {
        switch self {
            case .level1: "Level 1"
            case .level2: "Level 2"
            case .level3: "Level 3"
            case .level4: "Level 4"
            case .unknown: "Unknown"
        }
    }
    
    static func fromLabel(_ label: String) -> SchoolLevel? {
        switch label {
            case _ where label == SchoolLevel.level1.description: .level1
            case _ where label == SchoolLevel.level2.description: .level2
            case _ where label == SchoolLevel.level3.description: .level3
            case _ where label == SchoolLevel.level4.description: .level4
            default: nil
        }
    }
    
    static var all: [SchoolLevel] {
        [.level1, .level2, .level3, .level4]
    }
    
    var id: Int { self.rawValue }
    
    static func == (lhs: SchoolLevel, rhs: SchoolLevel) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
    
//    static func != (lhs: SchoolLevel, rhs: SchoolLevel) -> Bool {
//        !(lhs == rhs)
//    }
    
    static func < (lhs: SchoolLevel, rhs: SchoolLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
//    static func > (lhs: SchoolLevel, rhs: SchoolLevel) -> Bool {
//        lhs.rawValue > rhs.rawValue
//    }
}
