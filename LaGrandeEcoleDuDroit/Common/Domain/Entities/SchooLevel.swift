enum SchoolLevel: Int, Identifiable, Codable, CustomStringConvertible, Equatable, Comparable {
    case ged1 = 1
    case ged2 = 2
    case ged3 = 3
    case ged4 = 4
    case unknown = 0
    
    var description: String {
        switch self {
            case .ged1: "GED 1"
            case .ged2: "GED 2"
            case .ged3: "GED 3"
            case .ged4: "GED 4"
            case .unknown: "Unknown"
        }
    }
    
    static func fromLabel(_ label: String) -> SchoolLevel? {
        switch label {
            case _ where label == SchoolLevel.ged1.description: .ged1
            case _ where label == SchoolLevel.ged2.description: .ged2
            case _ where label == SchoolLevel.ged3.description: .ged3
            case _ where label == SchoolLevel.ged4.description: .ged4
            default: nil
        }
    }
    
    static var all: [SchoolLevel] {
        [.ged1, .ged2, .ged3, .ged4]
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
