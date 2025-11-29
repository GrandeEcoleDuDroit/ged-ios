import Foundation
import FirebaseCore
import CoreData

extension Conversation {
    func toLocal() -> LocalConversation {
        let localConversation = LocalConversation()
        localConversation.conversationId = id
        localConversation.conversationCreatedAt = createdAt
        localConversation.conversationState = state.rawValue
        localConversation.conversationInterlocutorId = interlocutor.id
        localConversation.conversationInterlocutorFirstName = interlocutor.firstName
        localConversation.conversationInterlocutorLastName = interlocutor.lastName
        localConversation.conversationInterlocutorEmail = interlocutor.email
        localConversation.conversationInterlocutorSchoolLevel = interlocutor.schoolLevel.rawValue
        localConversation.conversationInterlocutorAdmin = interlocutor.admin
        localConversation.conversationInterlocutorProfilePictureFileName = UrlUtils.extractFileNameFromUrl(url: interlocutor.profilePictureUrl)
        localConversation.conversationInterlocutorState = interlocutor.state.rawValue
        localConversation.conversationInterlocutorTester = interlocutor.tester
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
    
    func toRemoteNotificationMessageConversation() -> RemoteMessageNotification.Conversation {
        RemoteMessageNotification.Conversation(
            id: id,
            interlocutor: interlocutor.toRemoteNotificationMessageConversationInterlocutor(),
            createdAt: createdAt.toEpochMilli(),
            deleteTime: deleteTime?.toEpochMilli()
        )
    }
    
    func buildLocal(localConversation: LocalConversation) {
        localConversation.conversationId = id
        localConversation.conversationCreatedAt = createdAt
        localConversation.conversationState = state.rawValue
        localConversation.conversationInterlocutorId = interlocutor.id
        localConversation.conversationInterlocutorFirstName = interlocutor.firstName
        localConversation.conversationInterlocutorLastName = interlocutor.lastName
        localConversation.conversationInterlocutorEmail = interlocutor.email
        localConversation.conversationInterlocutorSchoolLevel = interlocutor.schoolLevel.rawValue
        localConversation.conversationInterlocutorAdmin = interlocutor.admin
        localConversation.conversationInterlocutorProfilePictureFileName = UrlUtils.extractFileNameFromUrl(url: interlocutor.profilePictureUrl)
        localConversation.conversationInterlocutorState = interlocutor.state.rawValue
        localConversation.conversationInterlocutorTester = interlocutor.tester
    }
}

extension LocalConversation {
    func toConversation() -> Conversation? {
        guard let id = conversationId,
              let createdAt = conversationCreatedAt,
              let state = ConversationState(rawValue: conversationState ?? ""),
              let interlocutorId = conversationInterlocutorId,
              let interlocutorFirstName = conversationInterlocutorFirstName,
              let interlocutorLastName = conversationInterlocutorLastName,
              let interlocutorEmail = conversationInterlocutorEmail,
              let interlocutorSchoolLevel = conversationInterlocutorSchoolLevel,
              let interlocutorProfilePictureFileName = conversationInterlocutorProfilePictureFileName,
              let interlocutorState = conversationInterlocutorState
        else { return nil }
        
        let interlocutor = User(
            id: interlocutorId,
            firstName: interlocutorFirstName,
            lastName: interlocutorLastName,
            email: interlocutorEmail,
            schoolLevel: SchoolLevel.init(rawValue: interlocutorSchoolLevel) ?? SchoolLevel.unknown,
            admin: conversationInterlocutorAdmin,
            profilePictureUrl: UrlUtils.formatOracleBucketUrl(fileName: interlocutorProfilePictureFileName),
            state: User.UserState(rawValue: interlocutorState) ?? .active,
            tester: conversationInterlocutorTester
        )
        
        return Conversation(
            id: id,
            interlocutor: interlocutor,
            createdAt: createdAt,
            state: state,
            deleteTime: conversationDeleteTime
        )
    }
    
    func modify(conversation: Conversation) {
        conversationId = conversation.id
        conversationCreatedAt = conversation.createdAt
        conversationState = conversation.state.rawValue
        conversationDeleteTime = conversation.deleteTime
        conversationInterlocutorId = conversation.interlocutor.id
        conversationInterlocutorFirstName = conversation.interlocutor.firstName
        conversationInterlocutorLastName = conversation.interlocutor.lastName
        conversationInterlocutorEmail = conversation.interlocutor.email
        conversationInterlocutorSchoolLevel = conversation.interlocutor.schoolLevel.rawValue
        conversationInterlocutorAdmin = conversation.interlocutor.admin
        conversationInterlocutorProfilePictureFileName = UrlUtils.extractFileNameFromUrl(url: conversation.interlocutor.profilePictureUrl)
        conversationInterlocutorState = conversation.interlocutor.state.rawValue
        conversationInterlocutorTester = conversation.interlocutor.tester
    }
    
    func equals(_ conversation: Conversation) -> Bool {
        conversationId == conversation.id &&
        conversationCreatedAt == conversation.createdAt &&
        conversationState == conversation.state.rawValue &&
        conversationDeleteTime == conversation.deleteTime &&
        conversationInterlocutorId == conversation.interlocutor.id &&
        conversationInterlocutorFirstName == conversation.interlocutor.firstName &&
        conversationInterlocutorLastName == conversation.interlocutor.lastName &&
        conversationInterlocutorEmail == conversation.interlocutor.email &&
        conversationInterlocutorSchoolLevel == conversation.interlocutor.schoolLevel.rawValue &&
        conversationInterlocutorAdmin == conversation.interlocutor.admin &&
        conversationInterlocutorProfilePictureFileName == UrlUtils.extractFileNameFromUrl(url: conversation.interlocutor.profilePictureUrl) &&
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
            deleteTime: deleteTime?[userId]?.dateValue()
        )
    }
    
    func toMap() -> [String: Any] {
        var data = [
            ConversationField.Remote.conversationId: conversationId,
            ConversationField.Remote.participants: participants,
            ConversationField.Remote.createdAt: createdAt
        ] as [String: Any]
        deleteTime.map { data[ConversationField.Remote.deleteTime] = $0 }
        return data
    }
}

private extension User {
    func toRemoteNotificationMessageConversationInterlocutor() -> RemoteMessageNotification.Conversation.Interlocutor {
        RemoteMessageNotification.Conversation.Interlocutor(
            id: id,
            firstName: firstName,
            lastName: lastName,
            fullName: fullName,
            email: email,
            schoolLevel: schoolLevel.rawValue,
            admin: admin,
            profilePictureFileName: UrlUtils.extractFileNameFromUrl(url: profilePictureUrl),
            state: state.rawValue,
            tester: tester
        )
    }
}
