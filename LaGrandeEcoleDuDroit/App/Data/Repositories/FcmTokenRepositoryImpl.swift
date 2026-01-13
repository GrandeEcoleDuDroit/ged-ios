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
        do {
            try await fcmApi.addToken(userId: userId, value: token)
        } catch {
            e(tag, "Error sending fcm token of user \(userId)", error)
            throw error
        }
    }
    
    func storeFcmToken(fcmToken: FcmToken) throws {
        do {
            try fcmLocalDataSource.storeFcmToken(fcmToken)
        } catch {
            e(tag, "Error storing fcm token", error)
            throw error
        }
    }
    
    func deleteToken(userId: String) async throws {
        do {
            if let token = fcmLocalDataSource.getFcmToken()?.token {
                try await fcmApi.deleteToken(userId: userId, value: token)
                fcmLocalDataSource.deleteFcmToken()
            }
        } catch {
            e(tag, "Error deleting fcm token of user \(userId)", error)
            throw error
        }
    }
}
