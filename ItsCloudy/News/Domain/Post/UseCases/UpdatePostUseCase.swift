import Foundation

class UpdatePostUseCase {
    private let postRepository: PostRepository
    
    init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }
    
    func execute(post: Post, imageReferences: [ImageReference]) async throws -> Void {
        var postToUpdate = post
        var imageFileData: [FileData] = []
        let imageData: [Data] = imageReferences.compactMap {
            if case let .imageData(data) = $0 {
                data
            } else {
                nil
            }
        }
        let imageUrls = imageReferences.filter {
            if case .imageUrl = $0 { true }
            else { false }
        }
        
        for data in imageData {
            guard let imageExtension = data.imageExtension() else { continue }
            let fileName = PostUtils.Image.generateFileName(postId: post.id) + "." + imageExtension
            let path = PostUtils.Image.getRelativePath(fileName: fileName)
            imageFileData.append(FileData(path: path, data: data))
        }
        
        let imagePaths = imageFileData.map(\.path)
        
        postToUpdate = postToUpdate.copy {
            $0.state = .published(imageUrls: imageUrls.compactMap(\.value) + imagePaths)
        }
        
        try await postRepository.updatePost(post: postToUpdate, imageFileData: imageFileData)
    }
}
