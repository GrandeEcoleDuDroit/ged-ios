struct User: Codable, Hashable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let schoolLevel: SchoolLevel
    let isMember: Bool
    let profilePictureUrl: String?
    
    var fullName: String {
        firstName + " " + lastName
    }
    
    func with(
        id: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        email: String? = nil,
        schoolLevel: SchoolLevel? = nil,
        isMember: Bool? = nil,
        profilePictureUrl: String? = nil
    ) -> User {
        User(
            id: id ?? self.id,
            firstName: firstName ?? self.firstName,
            lastName: lastName ?? self.lastName,
            email: email ?? self.email,
            schoolLevel: schoolLevel ?? self.schoolLevel,
            isMember: isMember ?? self.isMember,
            profilePictureUrl: profilePictureUrl ?? self.profilePictureUrl
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

struct UserWithImagePhase {
    let user: User
    let imagePhase: ImagePhase
}
