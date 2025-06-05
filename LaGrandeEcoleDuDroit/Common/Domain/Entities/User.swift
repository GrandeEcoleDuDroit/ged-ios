struct User: Decodable, Hashable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let schoolLevel: SchoolLevel
    let isMember: Bool
    let profilePictureFileName: String?
    
    var fullName: String {
        (firstName + " " + lastName).capitalized
    }
    
    func with(
        id: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        email: String? = nil,
        schoolLevel: SchoolLevel? = nil,
        isMember: Bool? = nil,
        profilePictureFileName: String? = nil
    ) -> User {
        User(
            id: id ?? self.id,
            firstName: firstName ?? self.firstName,
            lastName: lastName ?? self.lastName,
            email: email ?? self.email,
            schoolLevel: schoolLevel ?? self.schoolLevel,
            isMember: isMember ?? self.isMember,
            profilePictureFileName: profilePictureFileName ?? self.profilePictureFileName
        )
    }
}

enum SchoolLevel: String, CaseIterable, Identifiable, Decodable {
    case ged1 = "GED 1"
    case ged2 = "GED 2"
    case ged3 = "GED 3"
    case ged4 = "GED 4"
    
    var id: String { self.rawValue }
}
