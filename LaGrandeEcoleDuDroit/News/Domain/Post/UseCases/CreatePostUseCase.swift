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
        var imageFileData: [FileData] = []
        
        for data in imageData {
            guard let imageExtension = data.imageExtension() else { break }
            let fileName = PostUtils.Image.generateFileName(postId: post.id) + "." + imageExtension
            let path = PostUtils.Image.getRelativePath(fileName: fileName)
            try? await self.imageRepository.createLocalImage(imageData: data, imagePath: path)
            imageFileData.append(FileData(path: path, data: data))
        }
        
        let imagePaths = imageFileData.map(\.path)
        
        do {
            try await postRepository.createPost(
                post: post.copy { $0.state = .publishing(imagePaths: imagePaths) },
                imageFileData: imageFileData
            )
            
            try await postRepository.upsertLocalPost(post: post.copy { $0.state = .published(imageUrls: imagePaths) })
            
            for path in imagePaths {
                try? await imageRepository.deleteLocalImage(imagePath: path)
            }
        } catch {
            try? await postRepository.upsertLocalPost(
                post: post.copy { $0.state = .error(imagePaths: imagePaths) }
            )
        }
    }
}
