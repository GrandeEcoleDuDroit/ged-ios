import Foundation
import os

class AnnouncementApiImpl: AnnouncementApi {
    private let tokenProvider: TokenProvider
    private let base = "/announcements"
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func getAnnouncements() async throws -> [InboundRemoteAnnouncement] {
        let url = RequestUtils.getUrl(base: base)
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.simpleGetRequest(url: url, authToken: authToken)
        
        if let announcements: [InboundRemoteAnnouncement] = try await RequestUtils.sendDataRequest(session: session, request: request) {
            return announcements
        } else {
            throw NetworkError.unknown
        }
    }
    
    func createAnnouncement(remoteAnnouncement: OutbondRemoteAnnouncement) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/create")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: remoteAnnouncement, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func updateAnnouncement(remoteAnnouncement: OutbondRemoteAnnouncement) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/update")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: remoteAnnouncement, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func deleteAnnouncement(announcementId: String, authorId: String) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/delete")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let dataToSend = [
            AnnouncementField.Remote.announcementId: announcementId,
            AnnouncementField.Remote.userId: authorId
        ]
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: dataToSend, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func reportAnnouncement(report: RemoteAnnouncementReport) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/report")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: report, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
}
