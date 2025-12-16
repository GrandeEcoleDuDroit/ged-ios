enum TopLevelDestination: Hashable, Identifiable {
    case home
    case message
    case mission
    case profile
    
    var id: Int {
        switch self {
            case .home: 0
            case .message: 1
            case .mission: 2
            case .profile: 3
        }
    }
    
    var label: String {
        switch self {
            case .home: stringResource(.home)
            case .message: stringResource(.messages)
            case .mission: stringResource(.mission)
            case .profile: stringResource(.profile)
        }
    }
    
    var filledIcon: String {
        switch self {
            case .home: "house.fill"
            case .message: "message.fill"
            case .mission: "target"
            case .profile: "person.fill"
        }
    }
    
    var outlinedIcon: String {
        switch self {
            case .home: "house"
            case .message: "message"
            case .mission: "target"
            case .profile: "person"
        }
    }
}
