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
    
    func listenMessages(conversation: Conversation, offsetTime: Timestamp?) -> AnyPublisher<[RemoteMessage], Error> {
        let subject = PassthroughSubject<[RemoteMessage], Error>()
        
        let listener = conversationCollection
            .document(conversation.id.description)
            .collection(messageTableName)
            .withOffsetTime(offsetTime)
            .addSnapshotListener(includeMetadataChanges: true) { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                let messages = snapshot?.documents
                    .filter { !$0.metadata.hasPendingWrites && !$0.metadata.isFromCache }
                    .compactMap { try? $0.data(as: RemoteMessage.self) }
                
                subject.send(messages ?? [])
            }
        
        messageListeners.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    func createMessage(conversationId: String, messageId: String, data: [String: Any]) async throws {
        try await conversationCollection
            .document(conversationId)
            .collection(messageTableName)
            .document(messageId)
            .setData(data, merge: true)
    }
    
    func updateSeenMessage(remoteMessage: RemoteMessage) async throws {
        try await conversationCollection
            .document(remoteMessage.conversationId)
            .collection(messageTableName)
            .document(remoteMessage.messageId.toString())
            .updateData([MessageField.seen: remoteMessage.seen])
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
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func reportMessage(report: RemoteMessageReport) async throws -> (URLResponse, ServerResponse) {
        let url = try getUrl(endPoint: "report")
        let session = RequestUtils.getUrlSession()
        let authIdToken = await tokenProvider.getAuthIdToken()
        let request = try RequestUtils.formatPostRequest(
            dataToSend: report,
            url: url,
            authToken: authIdToken
        )
        
        return try await sendRequest(session: session, request: request)
    }
    
    private func getUrl(endPoint: String) throws -> URL {
        if let url = URL.oracleUrl(path: "/messages/\(endPoint)") {
            return url
        } else {
            throw NetworkError.invalidURL("Invalid URL")
        }
    }
    
    private func sendRequest(session: URLSession, request: URLRequest) async throws -> (URLResponse, ServerResponse) {
        let (dataReceived, response) = try await session.data(for: request)
        let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: dataReceived)
        return (response, serverResponse)
    }
}
