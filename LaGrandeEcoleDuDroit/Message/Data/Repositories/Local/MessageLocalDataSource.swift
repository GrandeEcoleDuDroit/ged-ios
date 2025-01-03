import Foundation
import Combine
import CoreData
import os

private let messageEntityName = "LocalMessage"
private let logger = Logger(subsystem: "com.upsaclay.gedoise", category: "MessageLocalDataSource")

class MessageLocalDataSource {
    private let tag = String(describing: MessageLocalDataSource.self)
    private let gedDatabaseContainer: GedDatabaseContainer
    private let request = NSFetchRequest<LocalMessage>(entityName: messageEntityName)
    private let context: NSManagedObjectContext
    let messageSubject = PassthroughSubject<Message, Error>()
    
    init(gedDatabaseContainer: GedDatabaseContainer) {
        self.gedDatabaseContainer = gedDatabaseContainer
        context = gedDatabaseContainer.container.viewContext
    }
    
    private func getMessages(conversationId: String, offeset: Int, limit: Int) {
        do {
            request.predicate = NSPredicate(format: "conversationId == %@", conversationId)
            request.fetchLimit = limit
            request.fetchOffset = offeset
            let localMessages = try context.fetch(request)
            localMessages.forEach { localMessage in
                if let message = MessageMapper.toDomain(localMessage: localMessage) {
                    messageSubject.send(message)
                }
            }
        } catch {
            e(tag, "Failed to get messages: \(error)")
            messageSubject.send(completion: .failure(MessageError.notFoundError))
        }
    }
    
    func insertMessage(message: Message) throws {
        do {
            MessageMapper.toLocal(message: message, context: context)
            try context.save()
            messageSubject.send(message)
        } catch {
            e(tag, "Failed to insert message: \(error)")
            throw MessageError.createMessageError
        }
    }
    
    func upsertMessage(message: Message) throws {
        request.predicate = NSPredicate(format: "messageId == %@", message.id)
        
        do {
            let localMessages = try context.fetch(request)
            
            if let localMessage = localMessages.first {
                localMessage.state = message.state.rawValue
                localMessage.isRead = message.isRead
            } else {
                MessageMapper.toLocal(message: message, context: context)
            }
            
            try context.save()
            messageSubject.send(message)
        } catch {
            e(tag, "Failed to upsert message: \(error)")
            throw MessageError.upsertMessageError
        }
    }
    
    func updateMessageState(messageId: String, state: MessageState) async throws {
        request.predicate = NSPredicate(format: "messageId == %@", messageId)
        
        do {
            let localMessages = try context.fetch(request)
            
            guard let localMessage = localMessages.first else {
                e(tag, "Message not found")
                throw MessageError.notFoundError
            }
            
            localMessage.state = state.rawValue
            try context.save()
            
            if let message = MessageMapper.toDomain(localMessage: localMessage) {
                messageSubject.send(message)
            }
        } catch {
            e(tag, "Failed to update message status: \(error)")
            throw MessageError.updateMessageError
        }
    }
}
