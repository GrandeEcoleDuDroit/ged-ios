import Foundation
import os

class AnnouncementApiImpl: AnnouncementApi {
    private let tokenProvider: TokenProvider
    private let base = "announcements"
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func getAnnouncements() async throws -> (URLResponse, [InboundRemoteAnnouncement]) {
        let url = try RequestUtils.formatOracleUrl(base: base)
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.simpleGetRequest(url: url, authToken: authToken)
        
        let (data, urlResponse) = try await session.data(for: request)
        let announcements = try JSONDecoder().decode([InboundRemoteAnnouncement].self, from: data)
        return (urlResponse, announcements)
    }
    
    func createAnnouncement(remoteAnnouncement: OutbondRemoteAnnouncement) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "create")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, authToken: authToken, dataToSend: remoteAnnouncement)
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func updateAnnouncement(remoteAnnouncement: OutbondRemoteAnnouncement) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "update")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, authToken: authToken, dataToSend: remoteAnnouncement)
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func deleteAnnouncements(userId: String) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "user/\(userId)")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.simpleDeleteRequest(url: url, authToken: authToken)
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func deleteAnnouncement(announcementId: String, authorId: String) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "delete")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let dataToSend = [
            AnnouncementField.Remote.announcementId: announcementId,
            AnnouncementField.Remote.userId: authorId
        ]
        let request = try RequestUtils.simplePostRequest(
            url: url,
            authToken: authToken,
            dataToSend: dataToSend
        )
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func reportAnnouncement(report: RemoteAnnouncementReport) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "report")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, authToken: authToken, dataToSend: report)
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
}
