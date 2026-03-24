import Combine

protocol PostRepository {
    var posts: AnyPublisher<[Post], Never> { get }
    
    func getPostPublisher(postId: String) -> AnyPublisher<Post?, Never>
    
    func getLocalPosts() async throws -> [Post]
    
    func getLocalPost(postId: String) async throws -> Post?

    func getRemotePosts() async throws -> [Post]
    
    func createPost(post: Post, imageFileData: [FileData]) async throws
    
    func updatePost(post: Post, imageFileData: [FileData]) async throws
    
    func upsertLocalPost(post: Post) async throws
    
    func deletePost(postId: String) async throws
    
    func deleteLocalPosts() async throws
    
    func deleteLocalPost(postId: String) async throws
}
