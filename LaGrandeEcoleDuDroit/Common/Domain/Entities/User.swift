struct User: Decodable, Hashable, Identifiable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var schoolLevel: String
    var isMember: Bool
    var profilePictureUrl: String?
    
    var fullName: String {
        return (firstName + " " + lastName).capitalized
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    func copy(
        id: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        email: String? = nil,
        schoolLevel: String? = nil,
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
