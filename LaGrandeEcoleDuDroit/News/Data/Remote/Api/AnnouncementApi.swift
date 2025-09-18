import Foundation

protocol AnnouncementApi {
    func getAnnouncements() async throws -> (URLResponse, [RemoteAnnouncementWithUser])
    
    func createAnnouncement(remoteAnnouncement: RemoteAnnouncement) async throws -> (URLResponse, ServerResponse)
    
    func updateAnnouncement(remoteAnnouncement: RemoteAnnouncement) async throws -> (URLResponse, ServerResponse)
    
    func deleteAnnouncement(remoteAnnouncementId: String) async throws -> (URLResponse, ServerResponse)
    
    func reportAnnouncement(report: AnnouncementReport) async throws -> (URLResponse, ServerResponse)
}
