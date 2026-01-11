import Combine
import Foundation
import FirebaseFirestore

class MessageApiImpl: MessageApi {
    private let messageTableName = "messages"
    private let tag = String(describing: MessageApiImpl.self)
    private var messageListeners: [ListenerRegistration] = []
    private let conversationCollection: CollectionReference = Firestore.firestore().collection(conversationTableName)
    private let messageServerApi: MessageServerApi
    
    init(messageServerApi: MessageServerApi) {
        self.messageServerApi = messageServerApi
    }
    
    func listenMessages(userId: String, conversation: Conversation, offsetTime: Timestamp?) -> AnyPublisher<RemoteMessage, Error> {
        let subject = PassthroughSubject<RemoteMessage, Error>()
        
        let listener = conversationCollection
            .document(conversation.id)
            .collection(messageTableName)
            .withOffsetTime(offsetTime)
            .addSnapshotListener(includeMetadataChanges: true) { snapshot, error in
                if let error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                snapshot?.documents
                    .filter { !$0.metadata.hasPendingWrites && !$0.metadata.isFromCache }
                    .forEach {
                        if let message = try? $0.data(as: RemoteMessage.self) {
                            subject.send(message)
                        }
                    }
            }
        
        messageListeners.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    func createMessage(remoteMessage: RemoteMessage) async throws {
        try await conversationCollection
            .document(remoteMessage.conversationId)
            .collection(messageTableName)
            .document(remoteMessage.messageId)
            .setData(remoteMessage.toMap(), merge: true)
    }
    
    func setMessageSeen(conversationId: String, messageId: String) async throws {
        try await conversationCollection
            .document(conversationId)
            .collection(messageTableName)
            .document(messageId)
            .updateData([MessageField.Remote.seen: true])
    }
    
    func updateMessageVisibility(remoteMessage: RemoteMessage, userId: String, visible: Bool) async throws {
        try await conversationCollection
            .document(remoteMessage.conversationId)
            .collection(messageTableName)
            .document(remoteMessage.messageId)
            .updateData(["\(MessageField.Remote.notVisibleFor).\(userId)": !visible])
    }
    
    func stopListeningMessages() {
        messageListeners.forEach { $0.remove() }
    }
    
    func reportMessage(report: MessageReport) async throws {
        try await messageServerApi.reportMessage(report: report.toRemote())
    }
}

class MessageServerApi {
    private let tokenProvider: TokenProvider
    private let base = "/messages"
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func reportMessage(report: RemoteMessageReport) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/report")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: report, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
}
