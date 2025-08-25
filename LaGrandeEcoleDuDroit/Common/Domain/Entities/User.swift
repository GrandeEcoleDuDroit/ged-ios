struct User: Codable, Hashable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let schoolLevel: SchoolLevel
    let isMember: Bool
    var profilePictureUrl: String?
    var imagePhase: ImagePhase
    
    var fullName: String {
        firstName + " " + lastName
    }
    
    init(
        id: String,
        firstName: String,
        lastName: String,
        email: String,
        schoolLevel: SchoolLevel,
        isMember: Bool = false,
        profilePictureUrl: String? = nil,
        imagePhase: ImagePhase = .empty
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.schoolLevel = schoolLevel
        self.isMember = isMember
        self.profilePictureUrl = profilePictureUrl
        self.imagePhase = imagePhase
    }
    
    func with(
        id: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        email: String? = nil,
        schoolLevel: SchoolLevel? = nil,
        isMember: Bool? = nil,
        profilePictureUrl: String? = nil,
        imagePhase: ImagePhase? = nil
    ) -> User {
        User(
            id: id ?? self.id,
            firstName: firstName ?? self.firstName,
            lastName: lastName ?? self.lastName,
            email: email ?? self.email,
            schoolLevel: schoolLevel ?? self.schoolLevel,
            isMember: isMember ?? self.isMember,
            profilePictureUrl: profilePictureUrl ?? self.profilePictureUrl,
            imagePhase: imagePhase ?? self.imagePhase
        )
    }
}

enum SchoolLevel: String, CaseIterable, Identifiable, Codable {
    case ged1 = "GED 1"
    case ged2 = "GED 2"
    case ged3 = "GED 3"
    case ged4 = "GED 4"
    
    var id: String { self.rawValue }
}
