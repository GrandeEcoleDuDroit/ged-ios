import Foundation

class CreatePostUseCase {
    private let postRepository: PostRepository
    private let imageRepository: ImageRepository
    
    init(
        postRepository: PostRepository,
        imageRepository: ImageRepository
    ) {
        self.postRepository = postRepository
        self.imageRepository = imageRepository
    }
    
    func execute(post: Post, imageData: [Data]) async {
        
    }
}
