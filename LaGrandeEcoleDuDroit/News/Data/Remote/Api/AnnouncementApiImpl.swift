import Foundation
import os

class AnnouncementApiImpl: AnnouncementApi {
    private let tokenProvider: TokenProvider
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    private func baseUrl(endPoint: String) -> URL? {
        URL.oracleUrl(endpoint: "/announcements" + endPoint)
    }
    
    func getAnnouncements() async throws -> (URLResponse, [RemoteAnnouncementWithUser]) {
        guard let url = baseUrl(endPoint: "") else {
            throw NetworkError.invalidURL("Invalid URL")
        }
        
        let session = RequestUtils.getUrlSession()
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
        guard let url = baseUrl(endPoint: "/create") else {
            throw NetworkError.invalidURL("Invalid URL")
        }
        
        let session = RequestUtils.getUrlSession()
        let authIdToken = await tokenProvider.getAuthIdToken()
        let request = try RequestUtils.formatPostRequest(
            dataToSend: remoteAnnouncement,
            url: url,
            authToken: authIdToken
        )
        
        let (data, urlResponse) = try await session.data(for: request)
        let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: data)
        return (urlResponse, serverResponse)
    }
    
    func deleteAnnouncement(remoteAnnouncementId: String) async throws -> (URLResponse, ServerResponse) {
        guard let url = baseUrl(endPoint: "/\(remoteAnnouncementId)") else {
            throw NetworkError.invalidURL("Invalid URL")
        }
        
        let session = RequestUtils.getUrlSession()
        let authIdToken = await tokenProvider.getAuthIdToken()
        let request = RequestUtils.formatDeleteRequest(
            url: url,
            authToken: authIdToken
        )
        
        let (data, urlResponse) = try await session.data(for: request)
        let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: data)
        return (urlResponse, serverResponse)
    }
    
    func updateAnnouncement(remoteAnnouncement: RemoteAnnouncement) async throws -> (URLResponse, ServerResponse) {
        guard let url = baseUrl(endPoint: "/update") else {
            throw NetworkError.invalidURL("Invalid URL")
        }
        
        let session = RequestUtils.getUrlSession()
        let authIdToken = await tokenProvider.getAuthIdToken()
        let request = try RequestUtils.formatPostRequest(
            dataToSend: remoteAnnouncement,
            url: url,
            authToken: authIdToken
        )
        
        let (data, urlResponse) = try await session.data(for: request)
        let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: data)
        return (urlResponse, serverResponse)
    }
}
