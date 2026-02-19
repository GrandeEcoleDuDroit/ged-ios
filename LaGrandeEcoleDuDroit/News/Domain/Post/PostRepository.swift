import Combine

protocol PostRepository {
    var posts: AnyPublisher<[Post], Never> { get }
    
    func getLocalPosts() async throws -> [Post]
    
    func getLocalPost(postId: String) async throws -> Post?

    func getRemotePosts() async throws -> [Post]
    
    func upsertLocalPost(post: Post) async throws
    
    func deleteLocalPost(postId: String) async throws
}
