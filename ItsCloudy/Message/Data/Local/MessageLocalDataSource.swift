import Combine
import CoreData

class MessageLocalDataSource {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    private let messageActor: MessageCoreDataActor

    init(gedDatabaseContainer: GedDatabaseContainer) {
        container = gedDatabaseContainer.container
        context = container.newBackgroundContext()
        messageActor = MessageCoreDataActor(context: context)
    }
    
    func listenDataChange() -> AnyPublisher<CoreDataChange<Message>, Never> {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: context)
            .collect(.byTime(RunLoop.current, .milliseconds(100)))
            .map { notifications in
                
                let extractIDs: (String) -> [NSManagedObjectID] = { key in
                    notifications.flatMap {
                        ($0.userInfo?[key] as? Set<NSManagedObject>)?
                            .compactMap { $0 as? LocalMessage }
                            .map(\.objectID) ?? []
                    }
                }
                
                let inserted = extractIDs(NSInsertedObjectsKey)
                let updated = extractIDs(NSUpdatedObjectsKey)
                
                return (inserted: inserted, updated: updated)
            }
            .flatMap { objectIds in
                Future<CoreDataChange<Message>, Never> { promise in
                    Task { [weak self] in
                        let inserted = await self?.messageActor.resolve(objectIds.inserted) ?? []
                        let updated = await self?.messageActor.resolve(objectIds.updated) ?? []
                        
                        promise(.success(CoreDataChange(inserted: inserted, updated: updated)))
                    }
                }.eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getMessages(conversationId: String, offset: Int, limit: Int) async throws -> [Message] {
        try await messageActor.getMessages(conversationId: conversationId, offset: offset, limit: limit)
    }
    
    func getLastMessage(conversationId: String) async throws -> Message? {
        try await messageActor.getLastMessage(conversationId: conversationId)
    }
    
    func getUserUnseenMessages(conversationId: String, userId: String) async throws -> [Message] {
        try await messageActor.getUserUnseenMessages(conversationId: conversationId, userId: userId)
    }
    
    func getUnsentMessages() async throws -> [Message] {
        try await messageActor.getUnsentMessages()
    }
    
    func insertMessage(message: Message) async throws {
        try await messageActor.insertMessage(message: message)
    }
  
    func upsertMessage(message: Message) async throws {
        try await messageActor.upsertMessage(message: message)
    }
    
    func updateMessage(message: Message) async throws {
        try await messageActor.updateMessage(message: message)
    }
    
    func setMessagesSeen(conversationId: String, currentUserId: String) async throws {
        try await messageActor.setMessagesSeen(conversationId: conversationId, userId: currentUserId)
    }
    
    func setMessageSeen(messageId: String) async throws {
        try await messageActor.setMessageSeen(messageId: messageId)
    }
    
    func deleteMessage(message: Message) async throws -> Message? {
        try await messageActor.deleteMessage(messageId: message.id)
    }
    
    func deleteMessages(conversationId: String) async throws -> [Message] {
        try await messageActor.deleteMessages(conversationId: conversationId)
    }
    
    func deleteMessages() async throws -> [Message] {
       try await messageActor.deleteMessages()
    }
}
