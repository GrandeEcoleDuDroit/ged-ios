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
    
    static func toUserLocal(user: User) -> UserLocal {
        return UserLocal(
            userId: user.id,
            userFirstName: user.firstName,
            userLastName: user.lastName,
            userEmail: user.email,
            userSchoolLevel: user.schoolLevel,
            userIsMember: user.isMember,
            userProfilePictureUrl: user.profilePictureUrl
        )
    }
    
    static func toDomain(userLocal: UserLocal) -> User {
        return User(
            id: userLocal.userId,
            firstName: userLocal.userFirstName,
            lastName: userLocal.userLastName,
            email: userLocal.userEmail,
            schoolLevel: userLocal.userSchoolLevel,
            isMember: userLocal.userIsMember,
            profilePictureUrl: userLocal.userProfilePictureUrl
        )
    }
    
    static func toDomain(firestoreUser: FirestoreUser) -> User {
        return User(
            id: firestoreUser.userId,
            firstName: firestoreUser.firstName,
            lastName: firestoreUser.lastName,
            email: firestoreUser.email,
            schoolLevel: firestoreUser.schoolLevel,
            isMember: firestoreUser.isMember,
            profilePictureUrl: firestoreUser.profilePictureUrl
        )
    }
}
