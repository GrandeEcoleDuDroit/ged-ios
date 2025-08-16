import Foundation

class FcmLocalDataSource {
    private let fcmTokenKey = "FCM_TOKEN_KEY"
    
    func getFcmToken() -> FcmToken? {
        guard let localFcmTokenData = UserDefaults.standard.data(forKey: fcmTokenKey) else {
            return nil
        }
        
        let localFcmToken = try? JSONDecoder().decode(FcmToken.self, from: localFcmTokenData)
        return localFcmToken
    }
    
    func storeFcmToken(_ fcmToken: FcmToken) throws {
        let fcmTokenJson = try JSONEncoder().encode(fcmToken)
        UserDefaults.standard.set(fcmTokenJson, forKey: fcmTokenKey)
    }
    
    func removeFcmToken() {
        UserDefaults.standard.removeObject(forKey: fcmTokenKey)
    }
}
