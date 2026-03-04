class DeletePostUseCase {
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
        switch post.state {
            case .draft:
                try await postRepository.deleteLocalPost(postId: post.id)
                
            case .publishing:
                try await postRepository.deleteLocalPost(postId: post.id)
                try await deleteLocalImages(paths: post.state.resolveImagePaths())

            case .published:
                try await postRepository.deletePost(postId: post.id)
                
            case .error:
                try await postRepository.deleteLocalPost(postId: post.id)
                try await deleteLocalImages(paths: post.state.resolveImagePaths())
        }
    }
    
    private func deleteLocalImages(paths: [String]) async throws {
        for path in paths {
            try await imageRepository.deleteLocalImage(imagePath: path)
        }
    }
}
