import Foundation
import FirebaseCore
import CoreData

extension Conversation {
    func toLocal() -> LocalConversation {
        let localConversation = LocalConversation()
        
        var conversationBlockedBy: String?
        if let data = try? JSONEncoder().encode(blockedBy) {
            conversationBlockedBy = String(data: data, encoding: .utf8)
        }
        
        localConversation.conversationId = id
        localConversation.conversationCreatedAt = createdAt
        localConversation.conversationState = state.rawValue
        localConversation.conversationEffectiveFrom = effectiveFrom
        localConversation.conversationBlockedBy = conversationBlockedBy
        localConversation.conversationInterlocutorId = interlocutor.id
        localConversation.conversationInterlocutorFirstName = interlocutor.firstName
        localConversation.conversationInterlocutorLastName = interlocutor.lastName
        localConversation.conversationInterlocutorEmail = interlocutor.email
        localConversation.conversationInterlocutorSchoolLevel = interlocutor.schoolLevel.rawValue
        localConversation.conversationInterlocutorAdmin = interlocutor.admin
        localConversation.conversationInterlocutorProfilePictureFileName = UserUtils.ProfilePicture.getFileName(url: interlocutor.profilePictureUrl)
        localConversation.conversationInterlocutorState = Int16(interlocutor.state.rawValue)
        localConversation.conversationInterlocutorTester = interlocutor.tester
        return localConversation
    }
    
    func toRemote(userId: String) -> RemoteConversation {
        RemoteConversation(
            conversationId: id,
            participants: [userId, interlocutor.id],
            createdAt: Timestamp(date: createdAt),
            effectiveFrom: effectiveFrom.map { [userId: Timestamp(date: $0)] },
            blockedBy: blockedBy?.filter { $0.key == userId }
        )
    }
    
    func buildLocal(localConversation: LocalConversation) {
        var conversationBlockedBy: String?
        if let data = try? JSONEncoder().encode(blockedBy) {
            conversationBlockedBy = String(data: data, encoding: .utf8)
        }
        
        localConversation.conversationId = id
        localConversation.conversationCreatedAt = createdAt
        localConversation.conversationState = state.rawValue
        localConversation.conversationEffectiveFrom = effectiveFrom
        localConversation.conversationBlockedBy = conversationBlockedBy
        localConversation.conversationInterlocutorId = interlocutor.id
        localConversation.conversationInterlocutorFirstName = interlocutor.firstName
        localConversation.conversationInterlocutorLastName = interlocutor.lastName
        localConversation.conversationInterlocutorEmail = interlocutor.email
        localConversation.conversationInterlocutorSchoolLevel = interlocutor.schoolLevel.rawValue
        localConversation.conversationInterlocutorAdmin = interlocutor.admin
        localConversation.conversationInterlocutorProfilePictureFileName = UserUtils.ProfilePicture.getFileName(url: interlocutor.profilePictureUrl)
        localConversation.conversationInterlocutorState = Int16(interlocutor.state.rawValue)
        localConversation.conversationInterlocutorTester = interlocutor.tester
    }
}

extension LocalConversation {
    func toConversation() -> Conversation? {
        guard let id = conversationId,
              let createdAt = conversationCreatedAt,
              let conversationState = conversationState,
              let state = Conversation.ConversationState(rawValue: conversationState),
              let interlocutorId = conversationInterlocutorId,
              let interlocutorFirstName = conversationInterlocutorFirstName,
              let interlocutorLastName = conversationInterlocutorLastName,
              let interlocutorEmail = conversationInterlocutorEmail,
              let interlocutorSchoolLevel = conversationInterlocutorSchoolLevel
        else { return nil }
        
        var blockedBy: [String: Bool]?
        if let data = conversationBlockedBy?.data(using: .utf8) {
            blockedBy = try? JSONDecoder().decode([String: Bool].self, from: data)
        }
        
        let interlocutor = User(
            id: interlocutorId,
            firstName: interlocutorFirstName,
            lastName: interlocutorLastName,
            email: interlocutorEmail,
            schoolLevel: SchoolLevel(rawValue: interlocutorSchoolLevel) ?? SchoolLevel.unknown,
            admin: conversationInterlocutorAdmin,
            profilePictureUrl: UserUtils.ProfilePicture.getUrl(fileName: conversationInterlocutorProfilePictureFileName),
            state: User.UserState(rawValue: Int(conversationInterlocutorState)) ?? .active,
            tester: conversationInterlocutorTester
        )
        
        return Conversation(
            id: id,
            interlocutor: interlocutor,
            createdAt: createdAt,
            state: state,
            effectiveFrom: conversationEffectiveFrom,
            blockedBy: blockedBy
        )
    }
    
    func modify(conversation: Conversation) {
        var blockedBy: String?
        if let data = try? JSONEncoder().encode(conversation.blockedBy) {
            blockedBy = String(data: data, encoding: .utf8)
        }
        
        conversationId = conversation.id
        conversationCreatedAt = conversation.createdAt
        conversationState = conversation.state.rawValue
        conversationEffectiveFrom = conversation.effectiveFrom
        conversationBlockedBy = blockedBy
        conversationInterlocutorId = conversation.interlocutor.id
        conversationInterlocutorFirstName = conversation.interlocutor.firstName
        conversationInterlocutorLastName = conversation.interlocutor.lastName
        conversationInterlocutorEmail = conversation.interlocutor.email
        conversationInterlocutorSchoolLevel = conversation.interlocutor.schoolLevel.rawValue
        conversationInterlocutorAdmin = conversation.interlocutor.admin
        conversationInterlocutorProfilePictureFileName = UserUtils.ProfilePicture.getFileName(url: conversation.interlocutor.profilePictureUrl)
        conversationInterlocutorState = Int16(conversation.interlocutor.state.rawValue)
        conversationInterlocutorTester = conversation.interlocutor.tester
    }
    
    func equals(_ conversation: Conversation) -> Bool {
        var blockedBy: String?
        if let data = try? JSONEncoder().encode(conversation.blockedBy) {
            blockedBy = String(data: data, encoding: .utf8)
        }
        
        return conversationId == conversation.id &&
            conversationCreatedAt == conversation.createdAt &&
            conversationState == conversation.state.rawValue &&
            conversationEffectiveFrom == conversation.effectiveFrom &&
            conversationBlockedBy == blockedBy &&
            conversationInterlocutorId == conversation.interlocutor.id &&
            conversationInterlocutorFirstName == conversation.interlocutor.firstName &&
            conversationInterlocutorLastName == conversation.interlocutor.lastName &&
            conversationInterlocutorEmail == conversation.interlocutor.email &&
            conversationInterlocutorSchoolLevel == conversation.interlocutor.schoolLevel.rawValue &&
            conversationInterlocutorAdmin == conversation.interlocutor.admin &&
            conversationInterlocutorProfilePictureFileName == UserUtils.ProfilePicture.getFileName(url: conversation.interlocutor.profilePictureUrl) &&
            conversationInterlocutorState == conversation.interlocutor.state.rawValue &&
            conversationInterlocutorTester == conversation.interlocutor.tester
    }
}

extension RemoteConversation {
    func toConversation(userId: String, interlocutor: User) -> Conversation {
        Conversation(
            id: conversationId,
            interlocutor: interlocutor,
            createdAt: createdAt.dateValue(),
            state: .created,
            effectiveFrom: effectiveFrom?[userId]?.dateValue(),
            blockedBy: blockedBy
        )
    }
    
    func toMap() -> [String: Any] {
        var data: [String: Any] = [
            ConversationField.Remote.conversationId: conversationId,
            ConversationField.Remote.participants: participants,
            ConversationField.Remote.createdAt: createdAt
        ]
        
        effectiveFrom.map { data[ConversationField.Remote.effectiveFrom] = $0 }
        blockedBy.map { data[ConversationField.Remote.blockedBy] = $0 }
        
        return data
    }
}
