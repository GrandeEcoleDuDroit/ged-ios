import CoreData

actor MessageCoreDataActor {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
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
    
    func resolve(_ ids: [NSManagedObjectID]) -> [Message] {
        self.context.performAndWait {
            ids.compactMap {
                guard let object = try? self.context.existingObject(with: $0) else {
                    return nil
                }
                return (object as? LocalMessage)?.toMessage()
            }
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
            
            guard localMessage?.equals(message) != true else { return }
            
            if let localMessage {
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
