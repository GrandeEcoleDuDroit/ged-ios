import Foundation
import FirebaseCore
import CoreData

extension RemoteConversation {
    func toConversation(userId: String, interlocutor: User) -> Conversation {
        Conversation(
            id: conversationId,
            interlocutor: interlocutor,
            createdAt: createdAt.dateValue(),
            state: .created,
            deleteTime: deleteTime?[userId]?.dateValue()
        )
    }
    
    func toMap() -> [String: Any] {
        var data = [
            ConversationField.conversationId: conversationId,
            ConversationField.Remote.participants: participants,
            ConversationField.createdAt: createdAt
        ] as [String: Any]
        deleteTime.map { data[ConversationField.deleteTime] = $0 }
        return data
    }
}

extension Conversation {
    func toLocal() -> LocalConversation? {
        let localConversation = LocalConversation()
        localConversation.conversationId = id
        localConversation.interlocutorId = interlocutor.id
        localConversation.interlocutorFirstName = interlocutor.firstName
        localConversation.interlocutorLastName = interlocutor.lastName
        localConversation.interlocutorEmail = interlocutor.email
        localConversation.interlocutorSchoolLevel = interlocutor.schoolLevel.rawValue
        localConversation.interlocutorIsMember = interlocutor.isMember
        localConversation.interlocutorProfilePictureFileName = UrlUtils.getFileNameFromUrl(
            url: interlocutor.profilePictureFileName
        )
        localConversation.createdAt = createdAt
        localConversation.state = state.rawValue
        return localConversation
    }
    
    func toRemote(userId: String) -> RemoteConversation {
        RemoteConversation(
            conversationId: id,
            participants: [userId, interlocutor.id],
            createdAt: Timestamp(date: createdAt),
            deleteTime: deleteTime.map { [userId: Timestamp(date: $0)] }
        )
    }
}

extension LocalConversation {
    func toConversation() -> Conversation? {
        guard let interlocutorId = interlocutorId,
              let interlocutorFirstName = interlocutorFirstName,
              let interlocutorLastName = interlocutorLastName,
              let interlocutorEmail = interlocutorEmail,
              let interlocutorSchoolLevel = interlocutorSchoolLevel,
              let id = conversationId,
              let createdAt = createdAt,
              let state = ConversationState(rawValue: state ?? "")
        else { return nil }
        
        let interlocutor = User(
            id: interlocutorId,
            firstName: interlocutorFirstName,
            lastName: interlocutorLastName,
            email: interlocutorEmail,
            schoolLevel: SchoolLevel.init(rawValue: interlocutorSchoolLevel) ?? SchoolLevel.ged1,
            isMember: interlocutorIsMember,
            profilePictureFileName: UrlUtils.formatProfilePictureUrl(
                fileName: interlocutorProfilePictureFileName
            )
        )
        
        return Conversation(
            id: id,
            interlocutor: interlocutor,
            createdAt: createdAt,
            state: state,
            deleteTime: deleteTime
        )
    }
}

