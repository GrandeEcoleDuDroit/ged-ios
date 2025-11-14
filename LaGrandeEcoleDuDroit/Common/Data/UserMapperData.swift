extension FirestoreUser {
    func toUser() -> User {
        User(
            id: userId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            schoolLevel: SchoolLevel(rawValue: schoolLevel) ?? .ged1,
            admin: admin,
            profilePictureUrl: UrlUtils.formatOracleBucketUrl(fileName: profilePictureFileName),
        )
    }
}

extension User {
    func toServerUser() -> ServerUser {
        ServerUser(
            userId: id,
            userFirstName: firstName,
            userLastName: lastName,
            userEmail: email,
            userSchoolLevel: schoolLevel.rawValue,
            userAdmin: admin ? 1 : 0,
            userProfilePictureFileName: UrlUtils.extractFileName(url: profilePictureUrl),
            userState: state.rawValue,
            userTester: tester ? 1 : 0
        )
    }
    
    func toFirestoreUser() -> FirestoreUser {
        FirestoreUser(
            userId: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            schoolLevel: schoolLevel.rawValue,
            admin: admin,
            profilePictureFileName: UrlUtils.extractFileName(url: profilePictureUrl),
            state: state.rawValue,
            tester: tester
        )
    }
    
    func toLocal() -> LocalUser {
        LocalUser(
            userId: id,
            userFirstName: firstName,
            userLastName: lastName,
            userEmail: email,
            userSchoolLevel: schoolLevel.rawValue,
            userAdmin: admin,
            userProfilePictureFileName: UrlUtils.extractFileName(url: profilePictureUrl),
            userState: state.rawValue,
            userTester: tester
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
            admin: userAdmin,
            profilePictureUrl: UrlUtils.formatOracleBucketUrl(fileName: userProfilePictureFileName),
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
