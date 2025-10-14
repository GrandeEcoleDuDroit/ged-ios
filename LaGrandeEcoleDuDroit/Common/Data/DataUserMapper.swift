extension FirestoreUser {
    func toUser() -> User {
        User(
            id: userId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            schoolLevel: SchoolLevel(rawValue: schoolLevel) ?? .ged1,
            isMember: isMember,
            profilePictureUrl: UrlUtils.formatOracleBucketUrl(fileName: profilePictureFileName),
            isDeleted: isDeleted
        )
    }
}

extension User {
    func toOracleUser() -> OracleUser {
        OracleUser(
            userId: id,
            userFirstName: firstName,
            userLastName: lastName,
            userEmail: email,
            userSchoolLevel: schoolLevel.rawValue,
            userIsMember: isMember ? 1 : 0,
            userProfilePictureFileName: UrlUtils.extractFileName(url: profilePictureUrl),
            userIsDeleted: isDeleted
        )
    }
    
    func toFirestoreUser() -> FirestoreUser {
        FirestoreUser(
            userId: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            schoolLevel: schoolLevel.rawValue,
            isMember: isMember,
            profilePictureFileName: UrlUtils.extractFileName(url: profilePictureUrl),
            isDeleted: isDeleted
        )
    }
    
    func toLocal() -> LocalUser {
        LocalUser(
            userId: id,
            userFirstName: firstName,
            userLastName: lastName,
            userEmail: email,
            userSchoolLevel: schoolLevel.rawValue,
            userIsMember: isMember,
            userProfilePictureFileName: UrlUtils.extractFileName(url: profilePictureUrl),
            userIsDeleted: isDeleted
        )
    }
}

extension LocalUser {
    func toUser() -> User {
        User(
            id: userId,
            firstName: userFirstName,
            lastName: userLastName,
            email: userEmail,
            schoolLevel: SchoolLevel.init(rawValue: userSchoolLevel)!,
            isMember: userIsMember,
            profilePictureUrl: UrlUtils.formatOracleBucketUrl(fileName: userProfilePictureFileName),
            isDeleted: userIsDeleted
        )
    }
}

extension UserReport {
    func toRemote() -> RemoteUserReport {
        RemoteUserReport(
            userId: userId,
            userInfo: userInfo.toRemote(),
            reporterInfo: reporterInfo.toRemote(),
            reason: reason.rawValue
        )
    }
}

extension UserReport.UserInfo {
    func toRemote() -> RemoteUserReport.RemoteUserInfo {
        RemoteUserReport.RemoteUserInfo(
            fullName: fullName,
            email: email
        )
    }
}
