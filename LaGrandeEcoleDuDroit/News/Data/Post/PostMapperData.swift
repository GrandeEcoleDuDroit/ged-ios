import Foundation

extension Post {
    func toRemote() -> RemotePost {
        let imageFileNames = extractImageFileNames(state: state)
        var postImageFileNames: String = "[]"
        
        if let data = try? JSONEncoder().encode(imageFileNames),
           let imageFileNamesJson = String(data: data, encoding: .utf8) {
            postImageFileNames = imageFileNamesJson
        }
        
        return RemotePost(
            postId: id,
            postTitle: title,
            postContent: content,
            postLink: link,
            postSourceId: source.id,
            postDate: date.toEpochMilli(),
            postImageFileNames: postImageFileNames
        )
    }
}

extension LocalPost {
    func toPost(getImagePath: (String) -> String?) -> Post? {
        guard let postId = postId,
              let postTitle = postTitle,
              let postContent = postContent,
              let postLink = postLink,
              let postDate = postDate,
              let postImageFileNames = postImageFileNames
        else { return nil }
        
        return Post(
            id: postId,
            title: postTitle,
            content: postContent,
            link: postLink,
            source: Post.PostSource(rawValue: Int(postSourceId)) ?? .unknown,
            date: postDate,
            state: mapLocalPostState(
                postState: postState,
                postImageFileNames: postImageFileNames,
                getImagePath: getImagePath
            )
        )
    }
    
    func modify(post: Post) {
        let imageFileNames = extractImageFileNames(state: post.state)
        
        postId = post.id
        postTitle = post.title
        postContent = post.content
        postLink = post.link
        postSourceId = Int16(post.source.rawValue)
        postDate = post.date
        if let data = try? JSONEncoder().encode(imageFileNames),
           let imageFileNamesJson = String(data: data, encoding: .utf8) {
            postImageFileNames = imageFileNamesJson
        }
        postState = Int16(post.state.id)
    }
    
    func equals(_ post: Post) -> Bool {
        let imageFileNames = extractImageFileNames(state: post.state)
        let postImageFileNamesArray: [String] = if let postImageFileNames {
            (try? JSONDecoder().decode([String].self, from: postImageFileNames.data(using: .utf8)!)) ?? []
        } else { [] }
        
        return (
            postId == post.id &&
            postTitle == post.title &&
            postContent == post.content &&
            postLink == post.link &&
            postSourceId == Int16(post.source.rawValue) &&
            postDate == post.date &&
            postImageFileNamesArray == imageFileNames &&
            postState == Int16(post.state.id)
        )
    }
}

extension RemotePost {
    func toPost() -> Post {
        Post(
            id: postId,
            title: postTitle,
            content: postContent,
            link: postLink,
            source: Post.PostSource(rawValue: postSourceId) ?? .unknown,
            date: postDate.toDate(),
            state: mapRemotePostState(postImageFileNames: postImageFileNames)
        )
    }
}

private func mapLocalPostState(
    postState: Int16,
    postImageFileNames: String,
    getImagePath: (String) -> String?
) -> Post.PostState {
    let imageFileNames = (
        try? JSONDecoder().decode(
            [String].self,
            from: postImageFileNames.data(using: .utf8)!
        )
    ) ?? []
    
    return switch postState {
        case _ where postState == Post.PostState.draft.id: .draft
        case _ where postState == Post.PostState.publishing().id: .publishing(imagePaths: imageFileNames.compactMap(getImagePath))
        case _ where postState == Post.PostState.published().id: .published(imageUrls: imageFileNames.compactMap(PostUtils.Image.formatUrl))
        default: .error(imagePaths: imageFileNames.compactMap(getImagePath))
    }
}

private func mapRemotePostState(postImageFileNames: String) -> Post.PostState {
    let imageFileNames = (
        try? JSONDecoder().decode(
            [String].self,
            from: postImageFileNames.data(using: .utf8)!
        )
    ) ?? []
    
    return .published(imageUrls: imageFileNames.compactMap(PostUtils.Image.formatUrl))
}

private func extractImageFileNames(state: Post.PostState) -> [String] {
    switch state {
        case .draft: []
        case let .publishing(imagePaths): imagePaths.compactMap(PostUtils.Image.extractFileName)
        case let .published(imageUrls): imageUrls.compactMap(PostUtils.Image.extractFileName)
        case let .error(imagePaths): imagePaths.compactMap(PostUtils.Image.extractFileName)
    }
}
