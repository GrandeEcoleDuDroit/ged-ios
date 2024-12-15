import Combine

protocol MessageApi {
    func listenMessages(conversationId: String) -> AnyPublisher<[RemoteMessage], Error>
    
    func listenLastMessage(conversationId: String) -> AnyPublisher<RemoteMessage?, Error>
    
    func stopListeningLastMessages()
}
