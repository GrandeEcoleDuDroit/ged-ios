extension User {
    func toServerUser() -> ServerUser {
        ServerUser(
            userId: id,
            userFirstName: firstName.lowercased(),
            userLastName: lastName.lowercased(),
            userEmail: email,
            userSchoolLevel: schoolLevel.number,
            userAdmin: admin ? 1 : 0,
            userProfilePictureFileName: UserUtils.ProfilePictureFile.getFileName(url: profilePictureUrl),
            userState: state.rawValue,
            userTester: tester ? 1 : 0
        )
    }
    
    func toFirestoreUser() -> FirestoreUser {
        FirestoreUser(
            userId: id,
            firstName: firstName.lowercased(),
            lastName: lastName.lowercased(),
            email: email,
            schoolLevel: schoolLevel.number,
            admin: admin,
            profilePictureFileName: UserUtils.ProfilePictureFile.getFileName(url: profilePictureUrl),
            state: state.rawValue,
            tester: tester
        )
    }
    
    func toLocal() -> LocalUser {
        LocalUser(
            userId: id,
            userFirstName: firstName.lowercased(),
            userLastName: lastName.lowercased(),
            userEmail: email,
            userSchoolLevel: schoolLevel.rawValue,
            userAdmin: admin,
            userProfilePictureFileName: UserUtils.ProfilePictureFile.getFileName(url: profilePictureUrl),
            userState: state.rawValue,
            userTester: tester
        )
    }
}

extension LocalUser {
    func toUser() -> User {
        User(
            id: userId,
            firstName: userFirstName.userNameFormatting(),
            lastName: userLastName.userNameFormatting(),
            email: userEmail,
            schoolLevel: SchoolLevel.init(rawValue: userSchoolLevel)!,
            admin: userAdmin,
            profilePictureUrl: UserUtils.ProfilePictureFile.url(fileName: userProfilePictureFileName)
        )
    }
}

extension FirestoreUser {
    func toUser() -> User {
        return User(
            id: userId,
            firstName: firstName.userNameFormatting(),
            lastName: lastName.userNameFormatting(),
            email: email,
            schoolLevel: SchoolLevel.fromNumber(schoolLevel),
            admin: admin,
            profilePictureUrl: UserUtils.ProfilePictureFile.url(fileName: profilePictureFileName),
            state: User.UserState(rawValue: state) ?? .active,
            tester: tester
        )
    }
}

extension ServerUser {
    func toUser() -> User {
        return User(
            id: userId,
            firstName: userFirstName,
            lastName: userLastName,
            email: userEmail,
            schoolLevel: SchoolLevel.fromNumber(userSchoolLevel),
            admin: userAdmin == 1,
            profilePictureUrl: UserUtils.ProfilePictureFile.url(fileName: userProfilePictureFileName),
            state: User.UserState(rawValue: userState) ?? .active,
            tester: userTester == 1
        )
    }
}

extension UserReport {
    func toRemote() -> RemoteUserReport {
        RemoteUserReport(
            userId: userId,
            reportedUser: reportedUser.toRemote(),
            reporter: reporterInfo.toRemote(),
            reason: reason.rawValue
        )
    }
}

private extension UserReport.ReportedUser {
    func toRemote() -> RemoteUserReport.RemoteReportedUser {
        RemoteUserReport.RemoteReportedUser(
            fullName: fullName,
            email: email
        )
    }
}

private extension UserReport.Reporter {
    func toRemote() -> RemoteUserReport.RemoteReporter {
        RemoteUserReport.RemoteReporter(
            fullName: fullName,
            email: email
        )
    }
}
