class WhiteListRepositoryImpl: WhiteListRepository {
    private let whiteListApi: WhiteListApi
    private let tag = String(describing: WhiteListRepositoryImpl.self)
    
    init(whiteListApi: WhiteListApi) {
        self.whiteListApi = whiteListApi
    }
    
    func isUserWhitelisted(email: String) async throws -> Bool {
        try await mapServerError(
            block: { try await whiteListApi.isUserWhiteListed(email: email) },
            tag: tag,
            message: "Failed to check if user is whitelisted"
        )
    }
}
