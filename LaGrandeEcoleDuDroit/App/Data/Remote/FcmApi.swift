import Foundation

protocol FcmApi {
    func addToken(userId: String, value: String) async throws
    
    func deleteToken(userId: String, value: String) async throws
    
    func sendNotification(userId: String, recipientId: String, fcmMessage: String) async throws
}
