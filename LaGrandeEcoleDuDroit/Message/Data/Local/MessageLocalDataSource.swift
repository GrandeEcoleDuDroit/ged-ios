import Foundation
import Combine
import CoreData
import os

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
            .compactMap {
                notifications -> (
                    inserted: [NSManagedObjectID],
                    updated: [NSManagedObjectID]
                )? in
                
                let extractIDs: (String) -> [NSManagedObjectID] = { key in
                    notifications.flatMap {
                        ($0.userInfo?[key] as? Set<NSManagedObject>)?
                            .compactMap { $0 as? LocalMessage }
                            .map(\.objectID) ?? []
                    }
                }
                
                let inserted = extractIDs(NSInsertedObjectsKey)
                let updated = extractIDs(NSUpdatedObjectsKey)
                
                guard !inserted.isEmpty || !updated.isEmpty else {
                    return nil
                }
                
                return (inserted: inserted, updated: updated)
            }
            .map { [weak self] objectIDs -> CoreDataChange<Message> in
                guard let self = self else {
                    return CoreDataChange(inserted: [], updated: [], deleted: [])
                }

                var inserted: [Message] = []
                var updated: [Message] = []

                self.context.performAndWait {
                    func resolve(_ ids: [NSManagedObjectID]) -> [Message] {
                        ids.compactMap {
                            guard let object = try? self.context.existingObject(with: $0),
                                  let local = object as? LocalMessage else {
                                return nil
                            }
                            return local.toMessage()
                        }
                    }

                    inserted = resolve(objectIDs.inserted)
                    updated = resolve(objectIDs.updated)
                }

                return CoreDataChange(inserted: inserted, updated: updated, deleted: [])
            }
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
            
            fetchRequest.fetchOffset = offset
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
    
    func getUnsentMessages() async throws -> [Message] {
        try await context.perform {
            let fetchRequest = LocalMessage.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "%K == %@",
                MessageField.Local.state, MessageState.sending.rawValue
            )
            
            return try self.context.fetch(fetchRequest).compactMap { $0.toMessage() }
        }
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
    
    func updateSeenMessages(conversationId: String, userId: String) async throws {
        try await messageActor.updateSeenMessages(conversationId: conversationId, userId: userId)
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

actor MessageCoreDataActor {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
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
            
            guard localMessage?.equals(message) != true else { return }
            
            if let localMessage = localMessage {
                localMessage.modify(message: message)
            } else {
                let newLocalMessage = LocalMessage(context: self.context)
                message.buildLocal(localMessage: newLocalMessage)
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
                format: "%K == %@ AND %K == %@ AND %K == %@",
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
    
    func deleteMessage(messageId: Int64) async throws -> Message? {
        try await context.perform {
            let request = LocalMessage.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %lld",
                MessageField.messageId, messageId
            )
            
            guard let localMessage = try self.context.fetch(request).first else {
                return nil
            }
            let message = localMessage.toMessage()
            self.context.delete(localMessage)
            try self.context.save()
            
            return message
        }
    }
    
    func deleteMessages(conversationId: String) async throws -> [Message] {
        try await context.perform {
            let request = LocalMessage.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %@",
                MessageField.conversationId, conversationId
            )
            
            let localMessages = try self.context.fetch(request)
            let messages = localMessages.compactMap { $0.toMessage() }
            localMessages.forEach {
                self.context.delete($0)
            }
            try self.context.save()
            
            return messages
        }
    }
    
    func deleteMessages() async throws -> [Message] {
        try await context.perform {
            let request = LocalMessage.fetchRequest()
            
            let localMessages = try self.context.fetch(request)
            let messages = localMessages.compactMap { $0.toMessage() }
            localMessages.forEach {
                self.context.delete($0)
            }
            try self.context.save()
            return messages
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
