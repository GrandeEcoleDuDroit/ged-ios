import Combine
import CoreData

class ConversationLocalDataSource {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    private let conversationActor: ConversationCoreDataActor

    init(gedDatabaseContainer: GedDatabaseContainer) {
        container = gedDatabaseContainer.container
        context = container.newBackgroundContext()
        conversationActor = ConversationCoreDataActor(context: context)
    }
    
    func listenDataChanges() -> AnyPublisher<CoreDataChange<Conversation>, Never> {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: context)
            .collect(.byTime(RunLoop.current, .milliseconds(100)))
            .map { notifications in
                
                let extractIDs: (String) -> [NSManagedObjectID] = { key in
                    notifications.flatMap {
                        ($0.userInfo?[key] as? Set<NSManagedObject>)?
                            .compactMap { $0 as? LocalConversation }
                            .map(\.objectID) ?? []
                    }
                }

                let inserted = extractIDs(NSInsertedObjectsKey)
                let updated = extractIDs(NSUpdatedObjectsKey)
              
                return (inserted: inserted, updated: updated)
            }
            .flatMap { objectIds in
                Future<CoreDataChange<Conversation>, Never> { promise in
                    Task { [weak self] in
                        let inserted = await self?.conversationActor.resolve(objectIds.inserted) ?? []
                        let updated = await self?.conversationActor.resolve(objectIds.updated) ?? []
                        
                        promise(.success(CoreDataChange(inserted: inserted, updated: updated)))
                    }
                }.eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func getConversations() async throws -> [Conversation] {
        try await conversationActor.getConversations()
    }
    
    func getConversation(interlocutorId: String) async throws -> Conversation? {
        try await conversationActor.getConversation(interlocutorId: interlocutorId)
    }
    
    func insertConversation(conversation: Conversation) async throws {
        try await conversationActor.insertConversation(conversation: conversation)
    }
    
    func upsertConversation(conversation: Conversation) async throws {
        try await conversationActor.upsertConversation(conversation: conversation)
    }
    
    func updateConversation(conversation: Conversation) async throws {
        try await conversationActor.updateConversation(conversation: conversation)
    }
    
    func deleteConversation(conversationId: String) async throws -> Conversation? {
        try await conversationActor.deleteConversation(conversationId: conversationId)
    }
    
    func deleteConversations() async throws -> [Conversation] {
        try await conversationActor.deleteConversations()
    }
}
