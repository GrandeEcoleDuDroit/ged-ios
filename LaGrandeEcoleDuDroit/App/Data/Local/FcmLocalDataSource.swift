import Foundation

class FcmLocalDataSource {
    private let fcmTokenKey = "fcmTokenKey"
    
    func getFcmToken() -> FcmToken? {
        guard let data = UserDefaults.standard.data(forKey: fcmTokenKey) else {
            return nil
        }
        return try? JSONDecoder().decode(FcmToken.self, from: data)
    }
    
    func storeFcmToken(_ fcmToken: FcmToken) throws {
        let fcmTokenJson = try JSONEncoder().encode(fcmToken)
        UserDefaults.standard.set(fcmTokenJson, forKey: fcmTokenKey)
    }
    
    func deleteFcmToken() {
        UserDefaults.standard.removeObject(forKey: fcmTokenKey)
    }
}
