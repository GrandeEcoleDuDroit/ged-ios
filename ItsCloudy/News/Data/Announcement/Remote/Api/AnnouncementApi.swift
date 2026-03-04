import Foundation

protocol AnnouncementApi {
    func getAnnouncements() async throws -> [InboundRemoteAnnouncement]
    
    func createAnnouncement(remoteAnnouncement: OutbondRemoteAnnouncement) async throws
    
    func updateAnnouncement(remoteAnnouncement: OutbondRemoteAnnouncement) async throws
    
    func deleteAnnouncement(announcementId: String, authorId: String) async throws
    
    func reportAnnouncement(report: RemoteAnnouncementReport) async throws
}
