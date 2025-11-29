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
    
    func listenMessages(conversation: Conversation, offsetTime: Timestamp?) -> AnyPublisher<RemoteMessage, Error> {
        let subject = PassthroughSubject<RemoteMessage, Error>()
        
        let listener = conversationCollection
            .document(conversation.id.description)
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
    
    func createMessage(conversationId: String, messageId: String, data: [String: Any]) async throws {
        let snapshot = try await conversationCollection.document(conversationId)
            .collection(messageTableName)
            .document(messageId)
            .getDocument(source: .server)
        
        if !snapshot.exists {
            try await conversationCollection
                .document(conversationId)
                .collection(messageTableName)
                .document(messageId)
                .setData(data, merge: true)
        }
    }
    
    func updateSeenMessage(remoteMessage: RemoteMessage) async throws {
        try await conversationCollection
            .document(remoteMessage.conversationId)
            .collection(messageTableName)
            .document(remoteMessage.messageId)
            .updateData([MessageField.Remote.seen: remoteMessage.seen])
    }
    
    func stopListeningMessages() {
        messageListeners.forEach { $0.remove() }
    }
    
    func reportMessage(report: MessageReport) async throws -> (URLResponse, ServerResponse) {
        try await messageServerApi.reportMessage(report: report.toRemote())
    }
}

class MessageServerApi {
    private let tokenProvider: TokenProvider
    private let base = "messages"
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func reportMessage(report: RemoteMessageReport) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "report")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(
            dataToSend: report,
            url: url,
            authToken: authToken
        )
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
}
