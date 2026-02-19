class FetchPostsUseCase {
    private let postRepository: PostRepository
    private let upsertLocalPostUseCase: UpsertLocalPostUseCase
    
    init(
        postRepository: PostRepository,
        upsertLocalPostUseCase: UpsertLocalPostUseCase
    ) {
        self.postRepository = postRepository
        self.upsertLocalPostUseCase = upsertLocalPostUseCase
    }
    
    func execute() async throws {
        let posts = try await postRepository.getLocalPosts()
        let remotePosts = try await postRepository.getRemotePosts()
        
        let postsToDelete = posts.filter { $0.state.type == .publishedType && !remotePosts.contains($0) }
        let postsToUpsert = remotePosts.filter { !posts.contains($0) }
        
        for post in postsToDelete {
            try? await postRepository.deleteLocalPost(postId: post.id)
        }
        
        for post in postsToUpsert {
            try await upsertLocalPostUseCase.execute(post: post)
        }
    }
}
