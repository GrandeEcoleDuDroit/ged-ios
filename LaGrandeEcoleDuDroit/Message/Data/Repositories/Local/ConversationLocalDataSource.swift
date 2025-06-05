import Foundation
import Combine
import CoreData

class ConversationLocalDataSource {
    private let container: NSPersistentContainer
    
    init(gedDatabaseContainer: GedDatabaseContainer) {
        container = gedDatabaseContainer.container
    }
    
    func getConversations() async throws -> [Conversation] {
        let context = container.newBackgroundContext()
        let fetchRequest = LocalConversation.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: ConversationField.createdAt.rawValue, ascending: false)]
        
        return try context.fetch(fetchRequest).compactMap { localConversation in
            localConversation.toConversation()
        }
    }
    
    func getConversation(interlocutorId: String) async throws -> Conversation? {
        let context = container.newBackgroundContext()
        let request: NSFetchRequest<LocalConversation> = LocalConversation.fetchRequest()
        request.predicate = NSPredicate(format: "\(ConversationField.Local.interlocutorId.rawValue) == %@", interlocutorId)
        
        return try context.fetch(request).compactMap {
            $0.toConversation()
        }.first
    }
    
    func updateConversation(conversation: Conversation) async throws {
        let context = container.newBackgroundContext()
        try await context.perform {
            try self.update(conversation: conversation, context: context)
        }
    }
    
    func upsertConversation(conversation: Conversation) async throws {
        let context = container.newBackgroundContext()
        try await context.perform {
            let request = LocalConversation.fetchRequest()
            request.predicate = NSPredicate(format: "\(ConversationField.conversationId.rawValue) == %@", conversation.id)
            if let localConversation = try context.fetch(request).first {
                try self.update(localConversation: localConversation, conversation: conversation, context: context)
            } else {
                try self.insert(conversation: conversation, context: context)
            }
        }
    }
    
    func deleteConversation(conversationId: String) async throws {
        let context = container.newBackgroundContext()
        try await context.perform {
            let request = LocalConversation.fetchRequest()
            request.predicate = NSPredicate(format: "\(ConversationField.conversationId.rawValue) == %@", conversationId)
            
            try context.fetch(request).first.map {
                context.delete($0)
                try context.save()
            }
        }
    }
    
    func deleteConversations() async throws {
        let context = container.newBackgroundContext()
        try await context.perform {
            let request = LocalConversation.fetchRequest()
            let localConversations = try context.fetch(request)
            for localConversation in localConversations {
                context.delete(localConversation)
            }
            try context.save()
        }
    }
    
    private func insert(conversation: Conversation, context: NSManagedObjectContext) throws {
        conversation.buildLocal(context: context)
        try context.save()
    }
    
    private func update(conversation: Conversation, context: NSManagedObjectContext) throws {
        let request = LocalConversation.fetchRequest()
        request.predicate = NSPredicate(format: "\(ConversationField.conversationId.rawValue) == %@", conversation.id)
        let localConversation = try context.fetch(request).first
        localConversation?.interlocutorId = conversation.interlocutor.id
        localConversation?.interlocutorFirstName = conversation.interlocutor.firstName
        localConversation?.interlocutorLastName = conversation.interlocutor.lastName
        localConversation?.interlocutorEmail = conversation.interlocutor.email
        localConversation?.interlocutorSchoolLevel = conversation.interlocutor.schoolLevel.rawValue
        localConversation?.interlocutorIsMember = conversation.interlocutor.isMember
        localConversation?.interlocutorProfilePictureFileName = UrlUtils.getFileNameFromUrl(url: conversation.interlocutor.profilePictureFileName)
        try context.save()
    }
    
    private func update(localConversation: LocalConversation, conversation: Conversation, context: NSManagedObjectContext) throws {
        localConversation.interlocutorId = conversation.interlocutor.id
        localConversation.interlocutorFirstName = conversation.interlocutor.firstName
        localConversation.interlocutorLastName = conversation.interlocutor.lastName
        localConversation.interlocutorEmail = conversation.interlocutor.email
        localConversation.interlocutorSchoolLevel = conversation.interlocutor.schoolLevel.rawValue
        localConversation.interlocutorIsMember = conversation.interlocutor.isMember
        localConversation.interlocutorProfilePictureFileName = UrlUtils.getFileNameFromUrl(
            url: conversation.interlocutor.profilePictureFileName
        )
        try context.save()
    }
}
