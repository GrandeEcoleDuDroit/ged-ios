import Foundation

class BlockedUserApiImpl: BlockedUserApi {
    private let tokenProvider: TokenProvider
    private let base = "/blocked-users"
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func getBlockedUsers(currentUserId: String) async throws -> [RemoteBlockedUser] {
        let url = RequestUtils.getUrl(base: base, endPoint: "/\(currentUserId)")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.simpleGetRequest(url: url, authToken: authToken)
        
        if let blockedUsers: [RemoteBlockedUser] = try await RequestUtils.sendDataRequest(session: session, request: request) {
            return blockedUsers
        } else {
            throw NetworkError.emptyResponse
        }
    }
    
    func addBlockedUser(remoteBlockedUser: RemoteBlockedUser) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/create")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: remoteBlockedUser, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func removeBlockedUser(currentUserId: String, blockedUserId: String) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/delete")
        let session = RequestUtils.getDefaultSession()
        let data = [
            BlockedUserField.Remote.userId: currentUserId,
            BlockedUserField.Remote.blockedUserId: blockedUserId
        ]
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: data, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
}
