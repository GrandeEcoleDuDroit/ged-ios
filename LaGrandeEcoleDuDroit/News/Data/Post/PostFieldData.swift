struct PostField {
    private init() {}
    
    struct Local {
        private init() {}

        static let postId = "postId"
        static let postTitle = "postTitle"
        static let postContent = "postContent"
        static let postLink = "postLink"
        static let postSourceId = "postSourceId"
        static let postDate = "postDate"
        static let postImageFileNames = "postImageFileNames"
        static let postState = "postState"
    }
    
    struct Remote {
        private init() {}
        
        static let postId = "POST_ID"
        static let postTitle = "POST_TITLE"
        static let postContent = "POST_CONTENT"
        static let postLink = "POST_LINK"
        static let postSourceId = "POST_SOURCE_ID"
        static let postDate = "POST_DATE"
        static let postImageFileNames = "POST_IMAGE_FILE_NAMES"
    }
}
