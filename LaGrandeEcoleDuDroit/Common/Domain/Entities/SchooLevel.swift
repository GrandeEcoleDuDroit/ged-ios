enum SchoolLevel: String, Identifiable, Codable {
    case ged1 = "GED 1"
    case ged2 = "GED 2"
    case ged3 = "GED 3"
    case ged4 = "GED 4"
    case unknown = "Unknown"
    
    var number: Int {
        switch self {
            case .ged1: 1
            case .ged2: 2
            case .ged3: 3
            case .ged4: 4
            default: 0
        }
    }
    
    static func fromNumber(_ number: Int) -> SchoolLevel {
        switch number {
            case 1: .ged1
            case 2: .ged2
            case 3: .ged3
            case 4: .ged4
            default: .unknown
        }
    }
    
    static var all: [SchoolLevel] {
        [.ged1, .ged2, .ged3, .ged4]
    }
    
    var id: Int { self.number }
}
