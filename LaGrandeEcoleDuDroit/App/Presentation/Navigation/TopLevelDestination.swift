enum TopLevelDestination: Hashable, CaseIterable {
    case home
    case message
    case profile
    
    var label: String {
        switch self {
            case .home: getString(.home)
            case .message: getString(.messages)
            case .profile: getString(.profile)
        }
    }
    
    var filledIcon: String {
        switch self {
            case .home: "house.fill"
            case .message: "message.fill"
            case .profile: "person.fill"
        }
    }
    
    var outlinedIcon: String {
        switch self {
            case .home: "house"
            case .message: "message"
            case .profile: "person"
        }
    }
}
