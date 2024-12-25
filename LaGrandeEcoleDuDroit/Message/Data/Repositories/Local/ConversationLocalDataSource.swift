import Foundation
import Combine
import CoreData
import os

private let conversationEntityName = "LocalConversation"

class ConversationLocalDataSource {
    private let tag = String(describing: ConversationLocalDataSource.self)
    private let request = NSFetchRequest<LocalConversation>(entityName: conversationEntityName)
    private let context: NSManagedObjectContext
    
    let conversationSubject: PassthroughSubject<LocalConversation, ConversationError> = PassthroughSubject()
    
    init(gedDatabaseContainer: GedDatabaseContainer) {
        context = gedDatabaseContainer.container.viewContext
        fetchConversations()
    }
    
    private func fetchConversations() {
        do {
            let conversations = try context.fetch(request)
            conversations.forEach {
                conversationSubject.send($0)
            }
        } catch {
            e(tag, "Failed to fetch conversations: \(error.localizedDescription)")
            conversationSubject.send(completion: .failure(ConversationError.notFound))
        }
    }
    
    func upsertConversation(conversation: Conversation, interlocutor: User) throws {
        do {
            if let localConversation = try context.fetch(request).first(where: { $0.conversationId == conversation.id }) {
                guard let interlocutorJson = try? JSONEncoder().encode(interlocutor),
                      let interlocutorJsonString = String(data: interlocutorJson, encoding: .utf8) else {
                    e(tag, "Failed to encode interlocutor")
                    return
                }
                
                localConversation.interlocutorJson = interlocutorJsonString
                try context.save()
                conversationSubject.send(localConversation)
            } else {
                try insertConversation(conversation: conversation, interlocutor: interlocutor)
            }
        } catch {
            e(tag, "Failed to upsert conversation: \(error.localizedDescription)")
            throw ConversationError.insertFailed
        }
    }
    
    func insertConversation(conversation: Conversation, interlocutor: User) throws {
        do {
            let localConversation = try ConversationMapper.toLocal(
                conversation: conversation,
                interlocutor: interlocutor,
                context: context
            )
            try context.save()
            conversationSubject.send(localConversation)
        } catch {
            e(tag, "Failed to insert conversation: \(error.localizedDescription)")
            throw ConversationError.insertFailed
        }
    }
    
    func deleteConversation(conversationId: String) throws {
        do {
            if let localConversation = try context.fetch(request).first(where: { $0.conversationId == conversationId }) {
                context.delete(localConversation)
                try context.save()
            }
        } catch {
            e(tag, "Failed to delete conversation: \(error.localizedDescription)")
            throw ConversationError.deleteFailed
        }
    }
    
    func stopListeningConversations() {
        conversationSubject.send(completion: .finished)
    }
}
