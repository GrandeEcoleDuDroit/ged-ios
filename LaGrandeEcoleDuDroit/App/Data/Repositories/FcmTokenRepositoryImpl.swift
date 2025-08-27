import Foundation

class FcmTokenRepositoryImpl: FcmTokenRepository {
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
        
        try await mapRetrofitError {
            try await fcmApi.addToken(userId: userId, value: token.value)
        }
    }
    
    func storeUnsetToken(token: FcmToken) async throws {
        try fcmLocalDataSource.storeFcmToken(token)
    }
    
    func removeUnsetToken() async throws {
        fcmLocalDataSource.removeFcmToken()
    }
}
