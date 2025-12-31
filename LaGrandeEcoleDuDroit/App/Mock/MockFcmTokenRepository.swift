class MockFcmTokenRepository: FcmTokenRepository {
    func getFcmToken() -> FcmToken? { nil }
    
    func sendFcmToken(userId: String, token: String) async throws {}
    
    func storeFcmToken(fcmToken: FcmToken) throws {}

    func deleteToken(userId: String) async throws {}
}
