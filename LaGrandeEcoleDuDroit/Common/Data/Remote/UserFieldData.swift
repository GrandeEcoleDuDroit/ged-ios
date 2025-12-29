struct UserField {
    private init() {}
    
    struct Server {
        private init() {}
        
        static let userId = "USER_ID"
        static let userFirstName = "USER_FIRST_NAME"
        static let userLastName = "USER_LAST_NAME"
        static let userEmail = "USER_EMAIL"
        static let userSchoolLevel = "USER_SCHOOL_LEVEL"
        static let userAdmin = "USER_IS_MEMBER"
        static let userProfilePictureFileName = "USER_PROFILE_PICTURE_FILE_NAME"
        static let userState = "USER_STATE"
        static let userTester = "USER_TESTER"
    }
    
    struct Firestore {
        private init() {}
        
        static let userId = "userId"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let email = "email"
        static let schoolLevel = "schoolLevel"
        static let admin = "admin"
        static let profilePictureFileName = "profilePictureFileName"
        static let state = "state"
        static let tester = "tester"
    }
}

struct BlockedUserField {
    private init() {}
    
    struct Server {
        private init() {}
        
        static let userId = "USER_ID"
        static let blockedUserId = "BLOCKED_USER_ID"
    }
}
