import FirebaseFirestore

class BlockedUserApiImpl: BlockedUserApi {
    private let tag = String(describing: BlockedUserApiImpl.self)
    private let blockedUserServerApi: BlockedUserServerApi
    
    init(blockedUserServerApi: BlockedUserServerApi) {
        self.blockedUserServerApi = blockedUserServerApi
    }
    
    func getBlockedUserIds(currentUserId: String) async throws -> [String] {
        try await mapServerError(
            block: {  try await blockedUserServerApi.getBlockedUserIds(currentUserId: currentUserId) },
            tag: tag,
            message: "Failed to get blocked user ids from Server"
        )
    }
    
    func blockUser(currentUserId: String, blockedUserId: String) async throws {
        try await mapServerError(
            block: {  try await blockedUserServerApi.addBlockedUser(currentUserId: currentUserId, blockedUserId: blockedUserId) },
            tag: tag,
            message: "Failed to block user from Server"
        )
    }
    
    func unblockUser(currentUserId: String, blockedUserId: String) async throws {
        try await mapServerError(
            block: {  try await blockedUserServerApi.removeBlockedUser(currentUserId: currentUserId, blockedUserId: blockedUserId) },
            tag: tag,
            message: "Failed to unblock user from Firestore"
        )
    }
}

class BlockedUserServerApi {
    private let tokenProvider: TokenProvider
    private let base = "blocked-users"
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func getBlockedUserIds(currentUserId: String) async throws -> (URLResponse, [String]) {
        let url = try RequestUtils.formatOracleUrl(base: base)
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.simpleGetRequest(url: url, authToken: authToken)
        
        let (data, urlResponse) = try await session.data(for: request)
        let blockedUserIds = try JSONDecoder().decode([String].self, from: data)
        return (urlResponse, blockedUserIds)
    }
    
    func addBlockedUser(currentUserId: String, blockedUserId: String) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "create")
        let session = RequestUtils.getDefaultSession()
        let dataToSend = [BlockedUserField.Server.blockedUserId: blockedUserId]
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: dataToSend, authToken: authToken)
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func removeBlockedUser(currentUserId: String, blockedUserId: String) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: blockedUserId)
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.simpleDeleteRequest(url: url, authToken: authToken)
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
}
