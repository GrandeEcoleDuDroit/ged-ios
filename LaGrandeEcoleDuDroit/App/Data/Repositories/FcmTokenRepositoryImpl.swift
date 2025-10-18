import Foundation

class FcmTokenRepositoryImpl: FcmTokenRepository {
    private let tag = String(describing: FcmTokenRepositoryImpl.self)
    private let fcmLocalDataSource: FcmLocalDataSource
    private let fcmApi: FcmApi
    
    init(
        fcmLocalDataSource: FcmLocalDataSource,
        fcmApi: FcmApi
    ) {
        self.fcmLocalDataSource = fcmLocalDataSource
        self.fcmApi = fcmApi
    }
    
    func getUnsetToken() async -> FcmToken? {
        fcmLocalDataSource.getFcmToken()
    }
    
    func sendFcmToken(token: FcmToken) async throws {
        guard let userId = token.userId else {
            throw NSError()
        }
        
        try await mapServerError(
            block: { try await fcmApi.addToken(userId: userId, value: token.value) },
            tag: tag,
            message: "Faield to add fcm token"
        )
    }
    
    func storeUnsetToken(token: FcmToken) async throws {
        try fcmLocalDataSource.storeFcmToken(token)
    }
    
    func removeUnsetToken() async throws {
        fcmLocalDataSource.removeFcmToken()
    }
}
