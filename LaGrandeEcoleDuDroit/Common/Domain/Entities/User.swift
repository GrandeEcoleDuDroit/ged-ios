struct User: Codable, Hashable, Identifiable, Copyable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var schoolLevel: SchoolLevel
    var admin: Bool
    var profilePictureUrl: String?
    var state: UserState
    var tester: Bool
    
    init(
        id: String,
        firstName: String,
        lastName: String,
        email: String,
        schoolLevel: SchoolLevel,
        admin: Bool = false,
        profilePictureUrl: String? = nil,
        state: UserState = .active,
        tester: Bool = false
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.schoolLevel = schoolLevel
        self.admin = admin
        self.profilePictureUrl = profilePictureUrl
        self.state = state
        self.tester = tester
    }
    
    var fullName: String {
        firstName + " " + lastName
    }
    
    var displayedName: String {
        if state == UserState.active {
            fullName
        } else {
            stringResource(.deletedUser)
        }
    }
    
    enum UserState: String, Codable {
        case active = "active"
        case deleted = "deleted"
    }
}
