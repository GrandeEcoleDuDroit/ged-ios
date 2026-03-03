import Combine

class MockPostRepository: PostRepository {
    var posts: AnyPublisher<[Post], Never> { Empty().eraseToAnyPublisher() }

    func getLocalPosts() async throws -> [Post] { [] }

    func getLocalPost(postId: String) async throws -> Post? { nil }

    func getRemotePosts() async throws -> [Post] { [] }

    func createPost(post: Post, imageFileData: [FileData]) async throws {}

    func upsertLocalPost(post: Post) async throws {}
    
    func deletePost(postId: String) async throws {}

    func deleteLocalPost(postId: String) async throws {}
}
