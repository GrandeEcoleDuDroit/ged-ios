import Foundation

class PostRemoteDataSource {
    private let postApi: PostApi
    
    init(postApi: PostApi) {
        self.postApi = postApi
    }
    
    func getPosts() async throws -> [Post] {
        try await postApi.getPosts().map { $0.toPost() }
    }
    
    func createPost(post: Post, imageFileData: [FileData]) async throws {
        try await postApi.createPost(remotePost: post.toRemote(), imageFileData: imageFileData)
    }
    
    func deletePost(postId: String) async throws {
        try await postApi.deletePost(postId: postId)
    }
}
