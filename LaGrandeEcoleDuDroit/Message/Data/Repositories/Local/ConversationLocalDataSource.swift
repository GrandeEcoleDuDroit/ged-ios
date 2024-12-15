import Foundation
import Combine
import CoreData
import os

private let conversationEntityName = "LocalConversation"

class ConversationLocalDataSource {
    private let tag = String(describing: ConversationLocalDataSource.self)
    private let request = NSFetchRequest<LocalConversation>(entityName: conversationEntityName)
    private let context: NSManagedObjectContext
    
    let conversations: CurrentValueSubject<[LocalConversation], Never> = .init([])
    
    init(gedDatabaseContainer: GedDatabaseContainer) {
        context = gedDatabaseContainer.container.viewContext
        fetchConversations()
    }
    
    private func fetchConversations() {
        do {
            conversations.send(try context.fetch(request))
        } catch {
            e(tag, "Failed to fetch conversations: \(error.localizedDescription)")
        }
    }
    
    func insertConversation(conversation: Conversation, interlocutor: User) {
        do {
            try ConversationMapper.toLocal(
                conversation: conversation,
                interlocutor: interlocutor,
                context: context
            )
            try context.save()
            fetchConversations()
        } catch {
            e(tag, "Failed to save conversation: \(error.localizedDescription)")
        }
    }
}
