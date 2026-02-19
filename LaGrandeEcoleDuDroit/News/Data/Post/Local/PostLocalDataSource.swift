import Combine
import CoreData

class PostLocalDataSource {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    private let postActor: PostCoreDataActor
    
    init(gedDatabaseContainer: GedDatabaseContainer) {
        container = gedDatabaseContainer.container
        context = container.newBackgroundContext()
        postActor = PostCoreDataActor(context: context)
    }
    
    func listenDataChange() -> AnyPublisher<Notification, Never> {
        NotificationCenter.default.publisher(
            for: .NSManagedObjectContextDidSave,
            object: context
        )
        .eraseToAnyPublisher()
    }
    
    func getPosts() async throws -> [Post] {
        try await postActor.getPosts().compactMap { $0.toPost(getImagePath: getImagePath) }
    }
    
    func getPost(postId: String) async throws -> Post? {
        try await postActor.getPost(postId: postId)?.toPost(getImagePath: getImagePath)
    }
    
    func upsertPost(post: Post) async throws {
        try await postActor.upsertLocalPost(post: post)
    }
    
    func deletePost(postId: String) async throws {
        try await postActor.delete(postId: postId)
    }
    
    private func getImagePath(_ fileName: String) -> String? {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        .first?
        .appending(path: PostUtils.Image.getRelativePath(fileName: fileName), directoryHint: .inferFromPath)
        .path()
    }
}
