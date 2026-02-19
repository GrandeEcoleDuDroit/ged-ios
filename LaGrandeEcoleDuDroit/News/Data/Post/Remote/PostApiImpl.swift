class PostApiImpl: PostApi {
    private let tokenProvider: TokenProvider
    private let base = "/posts"

    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func getPosts() async throws -> [RemotePost] {
        let url = RequestUtils.getUrl(base: base)
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.simpleGetRequest(url: url, authToken: authToken)
        
        if let missions: [RemotePost] = try await RequestUtils.sendDataRequest(session: session, request: request) {
            return missions
        } else {
            throw NetworkError.unknown
        }
    }
}
