import Foundation
import Combine
import CoreData

class ConversationLocalDataSource {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    init(gedDatabaseContainer: GedDatabaseContainer) {
        container = gedDatabaseContainer.container
        context = container.newBackgroundContext()
    }
    
    func listenDataChange() -> AnyPublisher<CoreDataChange<Conversation>, Never> {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: context)
            .compactMap { notification -> (inserted: [NSManagedObjectID], updated: [NSManagedObjectID], deleted: [NSManagedObjectID])? in
                let insertedIDs = (notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>)?
                    .compactMap { $0 as? LocalConversation }
                    .map { $0.objectID } ?? []

                let updatedIDs = (notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>)?
                    .compactMap { $0 as? LocalConversation }
                    .map { $0.objectID } ?? []

                let deletedIDs = (notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>)?
                    .compactMap { $0 as? LocalConversation }
                    .map { $0.objectID } ?? []

                if insertedIDs.isEmpty && updatedIDs.isEmpty && deletedIDs.isEmpty {
                    return nil
                }

                return (inserted: insertedIDs, updated: updatedIDs, deleted: deletedIDs)
            }
            .map { [weak self] objectIDs -> CoreDataChange<Conversation> in
                guard let self = self else {
                    return CoreDataChange(inserted: [], updated: [], deleted: [])
                }

                var inserted: [Conversation] = []
                var updated: [Conversation] = []
                var deleted: [Conversation] = []

                self.context.performAndWait {
                    inserted = objectIDs.inserted.compactMap {
                        (try? self.context.existingObject(with: $0) as? LocalConversation)?.toConversation()
                    }
                    updated = objectIDs.updated.compactMap {
                        (try? self.context.existingObject(with: $0) as? LocalConversation)?.toConversation()
                    }
                    deleted = objectIDs.deleted.compactMap {
                        (try? self.context.existingObject(with: $0) as? LocalConversation)?.toConversation()
                    }
                }

                return CoreDataChange(inserted: inserted, updated: updated, deleted: deleted)
            }
            .throttle(for: .milliseconds(100), scheduler: RunLoop.current, latest: false)
            .eraseToAnyPublisher()
    }
    
    func getConversations() async throws -> [Conversation] {
        try await context.perform {
            let fetchRequest = LocalConversation.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(
                key: ConversationField.createdAt,
                ascending: false
            )]
            
            return try self.context.fetch(fetchRequest).compactMap { $0.toConversation() }
        }
    }
    
    func getConversation(interlocutorId: String) async throws -> Conversation? {
        try await context.perform {
            let request = LocalConversation.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %@",
                ConversationField.Local.interlocutorId, interlocutorId
            )
            
            return try self.context.fetch(request).first?.toConversation()
        }
    }
    
    func getLastConversation() async throws -> Conversation? {
        try await context.perform {
            let request = LocalConversation.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(
                key: ConversationField.createdAt,
                ascending: false
            )]
            request.fetchLimit = 1
            
            return try self.context.fetch(request).first?.toConversation()
        }
    }
    
    func insertConversation(conversation: Conversation) async throws {
        try await context.perform {
            let localConversation = LocalConversation(context: self.context)
            conversation.buildLocal(localConversation: localConversation)
            
            try self.context.save()
        }
    }
    
    func upsertConversation(conversation: Conversation) async throws {
        try await context.perform {
            let request = LocalConversation.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %@",
                ConversationField.conversationId, conversation.id
            )
            
            let localConversation = try self.context.fetch(request).first
            
            guard localConversation?.equals(conversation) != true else {
                return
            }
            
            if localConversation != nil {
                localConversation!.modify(conversation: conversation)
            } else {
                let localConversation = LocalConversation(context: self.context)
                conversation.buildLocal(localConversation: localConversation)
            }
            
            try self.context.save()
        }
    }
    
    func updateConversation(conversation: Conversation) async throws {
        try await context.perform {
            let request = LocalConversation.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %@",
                ConversationField.conversationId, conversation.id
            )
            
            let localConversation = try self.context.fetch(request).first
            localConversation?.modify(conversation: conversation)
            
            try self.context.save()
        }
    }
    
    func deleteConversation(conversationId: String) async throws {
        try await context.perform {
            let request = LocalConversation.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %@",
                ConversationField.conversationId, conversationId
            )
            
            try self.context.fetch(request).first.map {
                self.context.delete($0)
            }
            
            try self.context.save()
        }
    }
    
    func deleteConversations() async throws {
        try await context.perform {
            let request = LocalConversation.fetchRequest()
            
            try self.context.fetch(request).forEach {
                self.context.delete($0)
            }
            
            try self.context.save()
        }
    }
}

private extension Conversation {
    func buildLocal(localConversation: LocalConversation) {
        localConversation.conversationId = id
        localConversation.createdAt = createdAt
        localConversation.state = state.rawValue
        localConversation.interlocutorId = interlocutor.id
        localConversation.interlocutorFirstName = interlocutor.firstName
        localConversation.interlocutorLastName = interlocutor.lastName
        localConversation.interlocutorEmail = interlocutor.email
        localConversation.interlocutorSchoolLevel = interlocutor.schoolLevel.rawValue
        localConversation.interlocutorIsMember = interlocutor.isMember
        localConversation.interlocutorProfilePictureFileName = UrlUtils.getFileNameFromUrl(
            url: interlocutor.profilePictureFileName
        )
    }
}

private extension LocalConversation {
    func modify(conversation: Conversation) {
        interlocutorId = conversation.interlocutor.id
        interlocutorFirstName = conversation.interlocutor.firstName
        interlocutorLastName = conversation.interlocutor.lastName
        interlocutorEmail = conversation.interlocutor.email
        interlocutorSchoolLevel = conversation.interlocutor.schoolLevel.rawValue
        interlocutorIsMember = conversation.interlocutor.isMember
        interlocutorProfilePictureFileName = UrlUtils.getFileNameFromUrl(url: conversation.interlocutor.profilePictureFileName)
    }
    
    func equals(_ conversation: Conversation) -> Bool {
        conversationId == conversation.id &&
        interlocutorId == conversation.interlocutor.id &&
        interlocutorFirstName == conversation.interlocutor.firstName &&
        interlocutorLastName == conversation.interlocutor.lastName &&
        interlocutorEmail == conversation.interlocutor.email &&
        interlocutorSchoolLevel == conversation.interlocutor.schoolLevel.rawValue &&
        interlocutorIsMember == conversation.interlocutor.isMember &&
        interlocutorProfilePictureFileName == UrlUtils.getFileNameFromUrl(url: conversation.interlocutor.profilePictureFileName)
    }
}
