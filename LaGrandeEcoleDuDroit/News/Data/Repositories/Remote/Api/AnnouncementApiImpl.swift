import Foundation

class AnnouncementApiImpl: AnnouncementApi {
    private func baseUrl(endPoint: String) -> URL? {
        URL.oracleUrl(endpoint: "/announcements" + endPoint)
    }
    
    func getAnnouncements() async throws -> [RemoteAnnouncementWithUser] {
        guard let url = baseUrl(endPoint: "") else {
            throw RequestError.invalidURL
        }
        
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([RemoteAnnouncementWithUser].self, from: data) 
    }
    
    func createAnnouncement(remoteAnnouncement: RemoteAnnouncement) async throws {
        guard let url = baseUrl(endPoint: "/create") else {
            throw RequestError.invalidURL
        }
        
        let session = DataUtils.getUrlSession()
        let postRequest = try DataUtils.formatPostRequest(dataToSend: remoteAnnouncement, url: url)
        
        let (dataReceived, response) = try await session.data(for: postRequest)
        let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: dataReceived)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                print(serverResponse.message)
            } else {
                throw RequestError.invalidResponse(serverResponse.error)
            }
        } else {
            throw RequestError.invalidResponse(serverResponse.error)
        }
    }
}
