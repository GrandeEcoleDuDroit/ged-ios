class UserMapper {
    static func toFirestoreUser(user: User) -> FirestoreUser {
        return FirestoreUser(
            userId: user.id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            schoolLevel: user.schoolLevel,
            isMember: user.isMember,
            profilePictureUrl: user.profilePictureUrl,
            isOnline: false
        )
    }
    
    static func toOracleUser(user: User) -> OracleUser {
        let userIsMember = if user.isMember {
            1
        } else {
            0
        }
        return OracleUser(
            userId: user.id,
            userFirstName: user.firstName,
            userLastName: user.lastName,
            userEmail: user.email,
            userSchoolLevel: user.schoolLevel,
            userIsMember: userIsMember,
            userProfilePictureUrl: user.profilePictureUrl
        )
    }
}
