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
}
