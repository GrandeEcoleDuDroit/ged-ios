class UpsertLocalPostUseCase {
    private let postRepository: PostRepository
    private let imageRepository: ImageRepository
    
    init(
        postRepository: PostRepository,
        imageRepository: ImageRepository
    ) {
        self.postRepository = postRepository
        self.imageRepository = imageRepository
    }
    
    func execute(post: Post) async throws {
        let localPost = try? await postRepository.getLocalPost(postId: post.id)
        try await postRepository.upsertLocalPost(post: post)
        
        if let paths = localPost?.state.resolveImagePaths() {
            for path in paths {
                try await imageRepository.deleteLocalImage(imagePath: path)
            }
        }
    }
}
