struct AnnouncementField {
    private init() {}
    
    struct Local {
        private init() {}

        static let announcementId = "announcementId"
        static let announcementTitle = "announcementTitle"
        static let announcementContent = "announcementContent"
        static let announcementDate = "announcementDate"
        static let announcementState = "announcementState"
        static let announcementAuthorId = "announcementAuthorId"
        static let announcementAuthorFirstName = "announcementAuthorFirstName"
        static let announcementAuthorLastName = "announcementAuthorLastName"
        static let announcementAuthorEmail = "announcementAuthorEmail"
        static let announcementAuthorSchoolLevel = "announcementAuthorSchoolLevel"
        static let announcementAuthorAdmin = "announcementAuthorAdmin"
        static let announcementAuthorProfilePictureFileName = "announcementAuthorProfilePictureFileName"
        static let announcementAuthorState = "announcementAuthorState"
        static let announcementAuthorTester = "announcementAuthorTester"
    }
    
    struct Remote {
        private init() {}
        
        static let announcementId = "ANNOUNCEMENT_ID"
        static let announcementTitle = "ANNOUNCEMENT_TITLE"
        static let announcementContent = "ANNOUNCEMENT_CONTENT"
        static let announcementDate = "ANNOUNCEMENT_DATE"
        static let userId = "USER_ID"
        static let userFirstName = "USER_FIRST_NAME"
        static let userLastName = "USER_LAST_NAME"
        static let userEmail = "USER_EMAIL"
        static let userSchoolLevel = "USER_SCHOOL_LEVEL"
        static let userAdmin = "USER_ADMIN"
        static let userProfilePictureFileName = "USER_PROFILE_PICTURE_FILE_NAME"
        static let userState = "USER_STATE"
        static let userTester = "USER_TESTER"
    }
}
