import Foundation
import Combine
import CoreData
import os

class MessageLocalDataSource {
    private let tag = String(describing: MessageLocalDataSource.self)
    private let container: NSPersistentContainer
    
    let messageSubject = PassthroughSubject<[LocalMessage], Error>()
    
    init(gedDatabaseContainer: GedDatabaseContainer) {
        container = gedDatabaseContainer.container
    }
    
    func getMessages(conversationId: String) async throws -> [Message] {
        let context = container.newBackgroundContext()
        let fetchRequest = LocalMessage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(MessageField.conversationId.rawValue) == %@", conversationId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: MessageField.timestamp.rawValue, ascending: false)]
        
        return try context.fetch(fetchRequest).compactMap {
            $0.toMessage()
        }
    }
    
    func getLastMessage(conversationId: String) async throws -> Message? {
        let context = container.newBackgroundContext()
        let fetchRequest: NSFetchRequest<LocalMessage> = LocalMessage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(MessageField.conversationId.rawValue) == %@", conversationId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: MessageField.timestamp.rawValue, ascending: false)]
        fetchRequest.fetchLimit = 1
        
        return try context.fetch(fetchRequest).compactMap {
            $0.toMessage()
        }.first
    }
  
    func upsertMessage(message: Message) async throws {
        let context = container.newBackgroundContext()
        try await context.perform {
            let request = LocalMessage.fetchRequest()
            request.predicate = NSPredicate(format: "\(MessageField.messageId.rawValue) == %@", message.id)
            
            let localMessages = try context.fetch(request)
            if let localMessage = localMessages.first {
                localMessage.state = message.state.rawValue
                localMessage.seen = message.seen
            } else {
                message.buildLocal(context: context)
            }
            
            try context.save()
        }
    }
    
    func updateMessage(message: Message) async throws {
        let context = container.newBackgroundContext()
        try await context.perform {
            let request = LocalMessage.fetchRequest()
            request.predicate = NSPredicate(format: "\(MessageField.messageId.rawValue) == %@", message.id)
            
            let localMessage = try context.fetch(request).first
            localMessage?.seen = message.seen
            localMessage?.state = message.state.rawValue
            
            try context.save()
        }
    }
    
    func deleteMessages(conversationId: String) async throws {
        let context = container.newBackgroundContext()
        try await context.perform {
            let request: NSFetchRequest<LocalMessage> = LocalMessage.fetchRequest()
            request.predicate = NSPredicate(format: "\(MessageField.conversationId.rawValue) == %@", conversationId)
            let localMessages = try context.fetch(request)
            localMessages.forEach {
                context.delete($0)
            }
            
            try context.save()
        }
    }
    
    func deleteMessages() async throws {
        let context = container.newBackgroundContext()
        try await context.perform {
            let request: NSFetchRequest<LocalMessage> = LocalMessage.fetchRequest()
            let localMessages = try context.fetch(request)
            localMessages.forEach {
                context.delete($0)
            }
            
            try context.save()
        }
    }
}
