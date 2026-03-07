import Foundation

class RecreatePostUseCase {
    private let postRepository: PostRepository
    private let imageRepository: ImageRepository
    
    init(
        postRepository: PostRepository,
        imageRepository: ImageRepository
    ) {
        self.postRepository = postRepository
        self.imageRepository = imageRepository
    }
    
    func execute(post: Post) async {
        if post.state.type == .errorType {
            let imagePaths = post.state.resolveImagePaths()
            var imageFileData: [FileData] = []
            
            for path in imagePaths {
                if let data = try? await imageRepository.getLocalImage(imagePath: path) {
                    imageFileData.append(FileData(path: path, data: data))
                }
            }
            
            do {
                try await postRepository.createPost(
                    post: post.copy { $0.state = .publishing(imagePaths: imagePaths) },
                    imageFileData: imageFileData
                )
                
                try await postRepository.upsertLocalPost(
                    post: post.copy { $0.state = .published(imageUrls: imagePaths) }
                )
            } catch {
                try? await postRepository.upsertLocalPost(
                    post: post.copy { $0.state = .error(imagePaths: imagePaths) }
                )
            }
        }
    }
}
