import Foundation

protocol FcmApi {
    func addToken(userId: String, value: String) async throws -> (URLResponse, ServerResponse)
    
    func sendNotification(recipientId: String, fcmMessage: String) async throws -> (URLResponse, ServerResponse)
}
