import Combine

class PostRepositoryImpl: PostRepository {
    private let postLocalDataSource: PostLocalDataSource
    private let postRemoteDataSource: PostRemoteDataSource
    
    private let tag = String(describing: PostRepositoryImpl.self)
    private var cancellables: Set<AnyCancellable> = []
    private var postsSubject = PassthroughSubject<[Post], Never>()
    var posts: AnyPublisher<[Post], Never> {
        let localPosts = Future<[Post], Never> { promise in
            Task { [weak self] in
                let posts = (try? await self?.postLocalDataSource.getPosts()) ?? []
                promise(.success(posts))
            }
        }
        
        return postsSubject
            .prepend(localPosts)
            .eraseToAnyPublisher()
    }
    
    init(
        postLocalDataSource: PostLocalDataSource,
        postRemoteDataSource: PostRemoteDataSource
    ) {
        self.postLocalDataSource = postLocalDataSource
        self.postRemoteDataSource = postRemoteDataSource
        listenDataChanges()
    }
    
    func getLocalPosts() async throws -> [Post] {
        do {
            return try await postLocalDataSource.getPosts()
        } catch {
            e(tag, "Error getting local posts", error)
            throw error
        }
    }
    
    func getLocalPost(postId: String) async throws -> Post? {
        do {
            return try await postLocalDataSource.getPost(postId: postId)
        } catch {
            e(tag, "Error getting local post", error)
            throw error
        }
    }
    
    func getRemotePosts() async throws -> [Post] {
        do {
            return try await postRemoteDataSource.getPosts()
        } catch {
            e(tag, "Error getting remote posts", error)
            throw error
        }
    }
    
    func createPost(post: Post, imageFileData: [FileData]) async throws {
        do {
            try await postLocalDataSource.upsertPost(post: post)
            try await postRemoteDataSource.createPost(post: post, imageFileData: imageFileData)
        } catch {
            e(tag, "Error creating post \(post.id)", error)
            throw error
        }
    }
    
    func upsertLocalPost(post: Post) async throws {
        do {
            try await postLocalDataSource.upsertPost(post: post)
        } catch {
            e(tag, "Error upserting local post \(post.id)", error)
            throw error
        }
    }
    
    func deleteLocalPost(postId: String) async throws {
        do {
            try await postLocalDataSource.deletePost(postId: postId)
        } catch {
            e(tag, "Error deleting local post \(postId)", error)
            throw error
        }
    }
    
    private func listenDataChanges() {
        postLocalDataSource.listenDataChange()
            .sink { [weak self] _ in
                self?.loadPosts()
            }.store(in: &cancellables)
    }
    
    private func loadPosts() {
        Task {
            if let posts = try? await postLocalDataSource.getPosts() {
                postsSubject.send(posts)
            }
        }
    }
}
