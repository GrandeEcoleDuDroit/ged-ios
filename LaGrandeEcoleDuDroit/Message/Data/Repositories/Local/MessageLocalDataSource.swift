import Foundation
import Combine
import CoreData
import os

class MessageLocalDataSource {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    let messageSubject = PassthroughSubject<[LocalMessage], Error>()
    
    init(gedDatabaseContainer: GedDatabaseContainer) {
        container = gedDatabaseContainer.container
        context = container.newBackgroundContext()
    }
    
    func listenDataChange() -> AnyPublisher<CoreDataChange<Message>, Never> {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: context)
            .compactMap { notification -> (inserted: [NSManagedObjectID], updated: [NSManagedObjectID], deleted: [NSManagedObjectID])? in
                let insertedIDs = (notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>)?
                    .compactMap { $0 as? LocalMessage }
                    .map { $0.objectID } ?? []

                let updatedIDs = (notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>)?
                    .compactMap { $0 as? LocalMessage }
                    .map { $0.objectID } ?? []

                let deletedIDs = (notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>)?
                    .compactMap { $0 as? LocalMessage }
                    .map { $0.objectID } ?? []

                if insertedIDs.isEmpty && updatedIDs.isEmpty && deletedIDs.isEmpty {
                    return nil
                }

                return (inserted: insertedIDs, updated: updatedIDs, deleted: deletedIDs)
            }
            .map { [weak self] objectIDs -> CoreDataChange<Message> in
                guard let self = self else {
                    return CoreDataChange(inserted: [], updated: [], deleted: [])
                }

                var inserted: [Message] = []
                var updated: [Message] = []
                var deleted: [Message] = []

                self.context.performAndWait {
                    inserted = objectIDs.inserted.compactMap {
                        (try? self.context.existingObject(with: $0) as? LocalMessage)?.toMessage()
                    }
                    updated = objectIDs.updated.compactMap {
                        (try? self.context.existingObject(with: $0) as? LocalMessage)?.toMessage()
                    }
                    deleted = objectIDs.deleted.compactMap {
                        (try? self.context.existingObject(with: $0) as? LocalMessage)?.toMessage()
                    }
                }

                return CoreDataChange(inserted: inserted, updated: updated, deleted: deleted)
            }
            .throttle(for: .milliseconds(100), scheduler: RunLoop.current, latest: false)
            .eraseToAnyPublisher()
    }
    
    func getMessages(conversationId: String, offset: Int) async throws -> [Message] {
        try await context.perform {
            let fetchRequest = LocalMessage.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "%K == %@",
                MessageField.conversationId, conversationId
            )
            fetchRequest.sortDescriptors = [NSSortDescriptor(
                key: MessageField.timestamp,
                ascending: false
            )]
            
            fetchRequest.fetchOffset = 0
            fetchRequest.fetchLimit = 20
            
            return try self.context.fetch(fetchRequest).compactMap { $0.toMessage() }
        }
    }
    
    func getLastMessage(conversationId: String) async throws -> Message? {
        try await context.perform {
            let fetchRequest = LocalMessage.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "%K == %@",
                MessageField.conversationId, conversationId
            )
            fetchRequest.sortDescriptors = [NSSortDescriptor(
                key: MessageField.timestamp,
                ascending: false
            )]
            fetchRequest.fetchLimit = 1
            
            let result = try self.context.fetch(fetchRequest)
            return result.compactMap { $0.toMessage() }.first
        }
    }
    
    func getUnreadMessagesByUser(conversationId: String, userId: String) async throws -> [Message] {
        try await context.perform {
            let fetchRequest = LocalMessage.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "%K == %@ AND %K == %@ AND %K == %@",
                MessageField.conversationId, conversationId,
                MessageField.seen, NSNumber(value: false),
                MessageField.recipientId, userId
            )
            let unreadMessages = try self.context.fetch(fetchRequest)
            return unreadMessages.compactMap { $0.toMessage() }
        }
    }
        
    
    func insertMessage(message: Message) async throws {
        try await context.perform {
            let localMessage = LocalMessage(context: self.context)
            message.buildLocal(localMessage: localMessage)
            try self.context.save()
        }
    }
  
    func upsertMessage(message: Message) async throws {
        try await context.perform {
            let request = LocalMessage.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %lld",
                MessageField.messageId, message.id
            )
            
            let localMessages = try self.context.fetch(request)
            let localMessage = localMessages.first
            
            guard localMessage?.equals(message) != true else {
                return
            }
            
            if localMessage != nil {
                localMessage!.modify(message: message)
            } else {
                let localMessage = LocalMessage(context: self.context)
                message.buildLocal(localMessage: localMessage)
            }
            
            try self.context.save()
        }
    }
    
    func updateMessage(message: Message) async throws {
        try await context.perform {
            let request = LocalMessage.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %lld",
                MessageField.messageId, message.id
            )
            
            try self.context.fetch(request).first?.modify(message: message)
            try self.context.save()
        }
    }
    
    func updateSeenMessages(conversationId: String, userId: String) async throws {
        try await context.perform {
            let request = LocalMessage.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %@ AND %K == %@",
                MessageField.conversationId, conversationId,
                MessageField.seen, NSNumber(value: false),
                MessageField.recipientId, userId
            )
            let unreadMessages = try self.context.fetch(request)
            guard !unreadMessages.isEmpty else {
                return
            }
            
            unreadMessages.forEach {
                $0.seen = true
            }
            try self.context.save()
        }
    }
    
    func deleteMessages(conversationId: String) async throws {
        try await context.perform {
            let request = LocalMessage.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %@",
                MessageField.conversationId, conversationId
            )
            
            try self.context.fetch(request).forEach {
                self.context.delete($0)
            }
            try self.context.save()
        }
    }
    
    func deleteMessages() async throws {
        try await context.perform {
            let request = LocalMessage.fetchRequest()
            try self.context.fetch(request).forEach {
                self.context.delete($0)
            }
            
            try self.context.save()
        }
    }
}

private extension Message {
    func buildLocal(localMessage: LocalMessage) {
        localMessage.messageId = Int64(id)
        localMessage.conversationId = conversationId
        localMessage.senderId = senderId
        localMessage.recipientId = recipientId
        localMessage.content = content
        localMessage.timestamp = date
        localMessage.seen = seen
        localMessage.state = state.rawValue
    }
}

private extension LocalMessage {
    func modify(message: Message) {
        state = message.state.rawValue
        seen = message.seen
    }
    
    func equals(_ message: Message) -> Bool {
        messageId == message.id &&
        senderId == message.senderId &&
        recipientId == message.recipientId &&
        conversationId == message.conversationId &&
        content == message.content &&
        timestamp == message.date &&
        seen == message.seen &&
        state == message.state.rawValue
    }
}
