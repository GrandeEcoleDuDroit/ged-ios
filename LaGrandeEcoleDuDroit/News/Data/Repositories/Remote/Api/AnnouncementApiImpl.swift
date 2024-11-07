import Foundation

class AnnouncementApiImpl: AnnouncementApi {
    func getAnnouncements() async throws -> [RemoteAnnouncement] {
        guard let url = URL.oracleUrl(endpoint: "/announcements") else {
            throw RequestError.invalidURL
        }
        
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([RemoteAnnouncement].self, from: data) 
    }
}
