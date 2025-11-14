import Foundation

protocol AnnouncementApi {
    func getAnnouncements() async throws -> (URLResponse, [InboundRemoteAnnouncement])
    
    func createAnnouncement(remoteAnnouncement: OutbondRemoteAnnouncement) async throws -> (URLResponse, ServerResponse)
    
    func updateAnnouncement(remoteAnnouncement: OutbondRemoteAnnouncement) async throws -> (URLResponse, ServerResponse)
    
    func deleteAnnouncements(userId: String) async throws -> (URLResponse, ServerResponse)
    
    func deleteAnnouncement(announcementId: String) async throws -> (URLResponse, ServerResponse)
    
    func reportAnnouncement(report: RemoteAnnouncementReport) async throws -> (URLResponse, ServerResponse)
}
