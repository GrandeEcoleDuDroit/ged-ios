class WhiteListRepositoryImpl: WhiteListRepository {
    private let whiteListApi: WhiteListApi
    private let tag = String(describing: WhiteListRepositoryImpl.self)
    
    init(whiteListApi: WhiteListApi) {
        self.whiteListApi = whiteListApi
    }
    
    func isUserWhitelisted(email: String) async throws -> Bool {
        do {
            return try await whiteListApi.isUserWhiteListed(email: email)
        } catch {
            e(tag, "Error getting white list status for user \(email)", error)
            throw error
        }
    }
}
