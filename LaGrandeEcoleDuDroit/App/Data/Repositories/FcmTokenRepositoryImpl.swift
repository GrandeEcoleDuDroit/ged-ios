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
    
    func getFcmToken() -> FcmToken? {
        fcmLocalDataSource.getFcmToken()
    }
    
    func sendFcmToken(userId: String, token: String) async throws {
        try await mapServerError(
            block: { try await fcmApi.addToken(userId: userId, value: token) },
            tag: tag,
            message: "Error sending fcm token"
        )
    }
    
    func storeFcmToken(fcmToken: FcmToken) throws {
        try fcmLocalDataSource.storeFcmToken(fcmToken)
    }
    
    func deleteToken(userId: String) async throws {
        if let token = fcmLocalDataSource.getFcmToken()?.token {
            try await mapServerError(
                block: { try await fcmApi.deleteToken(userId: userId, value: token) },
                tag: tag,
                message: "Error deleting fcm token"
            )
            
            fcmLocalDataSource.deleteFcmToken()
        }
    }
}
