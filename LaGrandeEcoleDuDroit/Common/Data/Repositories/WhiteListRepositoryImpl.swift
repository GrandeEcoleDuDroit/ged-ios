class WhiteListRepositoryImpl: WhiteListRepository {
    private let whiteListApi: WhiteListApi
    
    init(whiteListApi: WhiteListApi) {
        self.whiteListApi = whiteListApi
    }
    
    func isUserWhitelisted(email: String) async throws -> Bool {
        try await handleRetrofitError(
            block: { try await whiteListApi.isUserWhiteListed(email: email) }
        )
    }
}
