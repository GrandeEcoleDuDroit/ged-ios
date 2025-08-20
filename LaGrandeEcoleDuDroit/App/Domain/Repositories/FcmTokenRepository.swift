protocol FcmTokenRepository {
    func getUnsetToken() async -> FcmToken?
    
    func sendFcmToken(token: FcmToken) async throws
    
    func storeUnsetToken(token: FcmToken) async throws
    
    func removeUnsetToken() async throws
}
