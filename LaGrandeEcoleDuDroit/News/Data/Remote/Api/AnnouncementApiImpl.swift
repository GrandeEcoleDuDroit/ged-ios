import Foundation
import os

class AnnouncementApiImpl: AnnouncementApi {
    private let tokenProvider: TokenProvider
    private let base = "announcements"
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func getAnnouncements() async throws -> (URLResponse, [RemoteAnnouncementWithUser]) {
        let url = try RequestUtils.getUrl(base: base, endPoint: "")
        
        let session = RequestUtils.getSession()
        let authIdToken = await tokenProvider.getAuthIdToken()
        let request = RequestUtils.formatGetRequest(
            url: url,
            authToken: authIdToken
        )
        
        let (data, urlResponse) = try await session.data(for: request)
        let announcements = try JSONDecoder().decode([RemoteAnnouncementWithUser].self, from: data)
        return (urlResponse, announcements)
    }
    
    func createAnnouncement(remoteAnnouncement: RemoteAnnouncement) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.getUrl(base: base, endPoint: "create")

        let session = RequestUtils.getSession()
        let authIdToken = await tokenProvider.getAuthIdToken()
        let request = try RequestUtils.formatPostRequest(
            dataToSend: remoteAnnouncement,
            url: url,
            authToken: authIdToken
        )
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func updateAnnouncement(remoteAnnouncement: RemoteAnnouncement) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.getUrl(base: base, endPoint: "update")

        let session = RequestUtils.getSession()
        let authIdToken = await tokenProvider.getAuthIdToken()
        let request = try RequestUtils.formatPostRequest(
            dataToSend: remoteAnnouncement,
            url: url,
            authToken: authIdToken
        )
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func deleteAnnouncements(userId: String) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.getUrl(base: base, endPoint: "user/\(userId)")

        
        let session = RequestUtils.getSession()
        let authIdToken = await tokenProvider.getAuthIdToken()
        let request = RequestUtils.formatDeleteRequest(
            url: url,
            authToken: authIdToken
        )
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func deleteAnnouncement(announcementId: String) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.getUrl(base: base, endPoint: announcementId)

        
        let session = RequestUtils.getSession()
        let authIdToken = await tokenProvider.getAuthIdToken()
        let request = RequestUtils.formatDeleteRequest(
            url: url,
            authToken: authIdToken
        )
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func reportAnnouncement(report: RemoteAnnouncementReport) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.getUrl(base: base, endPoint: "report")
        
        let session = RequestUtils.getSession()
        let authIdToken = await tokenProvider.getAuthIdToken()
        let request = try RequestUtils.formatPostRequest(
            dataToSend: report,
            url: url,
            authToken: authIdToken
        )
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
}
