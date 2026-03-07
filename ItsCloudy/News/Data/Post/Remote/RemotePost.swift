struct RemotePost: Codable {
    let postId: String
    let postTitle: String
    let postContent: String?
    let postLink: String
    let postSourceId: Int
    let postDate: Int64
    let postImageFileNames: String
    
    enum CodingKeys: String, CodingKey {
        case postId = "POST_ID"
        case postTitle = "POST_TITLE"
        case postContent = "POST_CONTENT"
        case postLink = "POST_LINK"
        case postSourceId = "POST_SOURCE_ID"
        case postDate = "POST_DATE"
        case postImageFileNames = "POST_IMAGE_FILE_NAMES"
    }
    
    init(
        postId: String,
        postTitle: String,
        postContent: String?,
        postLink: String,
        postSourceId: Int,
        postDate: Int64,
        postImageFileNames: String
    ) {
        self.postId = postId
        self.postTitle = postTitle
        self.postContent = postContent
        self.postLink = postLink
        self.postSourceId = postSourceId
        self.postDate = postDate
        self.postImageFileNames = postImageFileNames
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postId = try container.decode(String.self, forKey: .postId)
        self.postTitle = try container.decode(String.self, forKey: .postTitle)
        self.postContent = try container.decodeIfPresent(String.self, forKey: .postContent)
        self.postLink = try container.decode(String.self, forKey: .postLink)
        self.postSourceId = try container.decode(Int.self, forKey: .postSourceId)
        self.postDate = try container.decode(Int64.self, forKey: .postDate)
        self.postImageFileNames = try container.decodeIfPresent(String.self, forKey: .postImageFileNames) ?? "[]"
    }
}
