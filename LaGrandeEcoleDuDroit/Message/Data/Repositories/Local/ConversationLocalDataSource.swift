import Foundation
import Combine
import CoreData
import os

private let conversationEntityName = "LocalConversation"
private let tag = String(describing: ConversationLocalDataSource.self)

class ConversationLocalDataSource {
    private let request = NSFetchRequest<LocalConversation>(entityName: conversationEntityName)
    private let context: NSManagedObjectContext
    
    let conversationSubject = PassthroughSubject<LocalConversation, ConversationError>()
    
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
            throw ConversationError.createFailed
        }
    }
    
    func upsertConversation(conversation: Conversation, interlocutor: User) throws {
        request.predicate = NSPredicate(format: "conversationId == %@", conversation.id)
        
        do {
            let localConversations = try context.fetch(request)
            
            if let localConversation = localConversations.first {
                guard let interlocutorJson = try? JSONEncoder().encode(interlocutor),
                      let interlocutorJsonString = String(data: interlocutorJson, encoding: .utf8) else {
                    e(tag, "Failed to encode interlocutor")
                    return
                }
                
                localConversation.interlocutorJson = interlocutorJsonString
                
                try context.save()
                conversationSubject.send(localConversation)
            } else {
                let localConversation = try ConversationMapper.toLocal(
                    conversation: conversation,
                    interlocutor: interlocutor,
                    context: context
                )
                
                try context.save()
                conversationSubject.send(localConversation)
            }
        } catch {
            e(tag, "Failed to upsert conversation: \(error.localizedDescription)")
            throw ConversationError.upsertFailed
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
