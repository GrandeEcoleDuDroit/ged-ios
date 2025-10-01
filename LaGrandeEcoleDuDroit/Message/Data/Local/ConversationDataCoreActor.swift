import CoreData

actor ConversationCoreDataActor {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
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
    
    func resolve(_ ids: [NSManagedObjectID]) -> [Conversation] {
        self.context.performAndWait {
            ids.compactMap {
                guard let object = try? self.context.existingObject(with: $0) else {
                    return nil
                }
                return (object as? LocalConversation)?.toConversation()
            }
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
                localConversation?.modify(conversation: conversation)
            } else {
                let newLocalConversation = LocalConversation(context: self.context)
                conversation.buildLocal(localConversation: newLocalConversation)
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
    
    func deleteConversation(conversationId: String) async throws -> Conversation? {
        try await context.perform {
            let request = LocalConversation.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %@",
                ConversationField.conversationId, conversationId
            )
            
            guard let localConversation = try self.context.fetch(request).first else {
                return nil
            }
            let conversation = localConversation.toConversation()
            self.context.delete(localConversation)
            try self.context.save()
            
            return conversation
        }
    }
    
    func deleteConversations() async throws -> [Conversation] {
        try await context.perform {
            let request = LocalConversation.fetchRequest()
            
            let localConversations = try self.context.fetch(request)
            let conversations = localConversations.compactMap { $0.toConversation() }
            localConversations.forEach {
                self.context.delete($0)
            }
            try self.context.save()
            
            return conversations
        }
    }
}

private extension Conversation {
    func buildLocal(localConversation: LocalConversation) {
        localConversation.conversationId = id
        localConversation.createdAt = createdAt
        localConversation.state = state.rawValue
        localConversation.deleteTime = deleteTime
        localConversation.interlocutorId = interlocutor.id
        localConversation.interlocutorFirstName = interlocutor.firstName
        localConversation.interlocutorLastName = interlocutor.lastName
        localConversation.interlocutorEmail = interlocutor.email
        localConversation.interlocutorSchoolLevel = interlocutor.schoolLevel.rawValue
        localConversation.interlocutorIsMember = interlocutor.isMember
        localConversation.interlocutorProfilePictureFileName = UrlUtils.extractFileName(
            url: interlocutor.profilePictureUrl
        )
    }
}

private extension LocalConversation {
    func modify(conversation: Conversation) {
        conversationId = conversation.id
        createdAt = conversation.createdAt
        state = conversation.state.rawValue
        deleteTime = conversation.deleteTime
        interlocutorId = conversation.interlocutor.id
        interlocutorFirstName = conversation.interlocutor.firstName
        interlocutorLastName = conversation.interlocutor.lastName
        interlocutorEmail = conversation.interlocutor.email
        interlocutorSchoolLevel = conversation.interlocutor.schoolLevel.rawValue
        interlocutorIsMember = conversation.interlocutor.isMember
        interlocutorProfilePictureFileName = UrlUtils.extractFileName(url: conversation.interlocutor.profilePictureUrl)
    }
    
    func equals(_ conversation: Conversation) -> Bool {
        conversationId == conversation.id &&
        createdAt == conversation.createdAt &&
        state == conversation.state.rawValue &&
        deleteTime == conversation.deleteTime &&
        interlocutorId == conversation.interlocutor.id &&
        interlocutorFirstName == conversation.interlocutor.firstName &&
        interlocutorLastName == conversation.interlocutor.lastName &&
        interlocutorEmail == conversation.interlocutor.email &&
        interlocutorSchoolLevel == conversation.interlocutor.schoolLevel.rawValue &&
        interlocutorIsMember == conversation.interlocutor.isMember &&
        interlocutorProfilePictureFileName == UrlUtils.extractFileName(url: conversation.interlocutor.profilePictureUrl)
    }
}
