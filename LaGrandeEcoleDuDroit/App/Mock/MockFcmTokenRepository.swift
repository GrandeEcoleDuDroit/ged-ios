class MockFcmTokenRepository: FcmTokenRepository {
    func getUnsetToken() async -> FcmToken? { nil }
    
    func sendFcmToken(token: FcmToken) async throws {}
    
    func storeUnsetToken(token: FcmToken) async throws {}
    
    func removeUnsetToken() async throws {}
}
