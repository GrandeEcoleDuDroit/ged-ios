enum TopLevelDestination: Hashable, CaseIterable {
    case home
    case message
    case mission
    case profile
    
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
