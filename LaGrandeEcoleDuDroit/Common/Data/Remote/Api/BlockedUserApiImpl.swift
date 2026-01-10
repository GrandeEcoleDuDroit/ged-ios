import FirebaseFirestore

class BlockedUserApiImpl: BlockedUserApi {
    private let blockedUserServerApi: BlockedUserServerApi
    
    init(blockedUserServerApi: BlockedUserServerApi) {
        self.blockedUserServerApi = blockedUserServerApi
    }
    
    func getBlockedUserIds(currentUserId: String) async throws -> [String] {
        try await blockedUserServerApi.getBlockedUserIds(currentUserId: currentUserId)
    }
    
    func blockUser(currentUserId: String, blockedUserId: String) async throws {
        try await blockedUserServerApi.addBlockedUser(
            currentUserId: currentUserId,
            blockedUserId: blockedUserId
        )
    }
    
    func unblockUser(currentUserId: String, blockedUserId: String) async throws {
        try await blockedUserServerApi.removeBlockedUser(
            currentUserId: currentUserId,
            blockedUserId: blockedUserId
        )
    }
}

class BlockedUserServerApi {
    private let tokenProvider: TokenProvider
    private let base = "/blocked-users"
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func getBlockedUserIds(currentUserId: String) async throws -> [String] {
        let url = RequestUtils.getUrl(base: base)
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.simpleGetRequest(url: url, authToken: authToken)
        
        return try await RequestUtils.sendDataRequest(session: session, request: request) ?? []
    }
    
    func addBlockedUser(currentUserId: String, blockedUserId: String) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/create")
        let session = RequestUtils.getDefaultSession()
        let dataToSend = [BlockedUserField.Server.blockedUserId: blockedUserId]
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: dataToSend, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func removeBlockedUser(currentUserId: String, blockedUserId: String) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/\(blockedUserId)")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.simpleDeleteRequest(url: url, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
}
