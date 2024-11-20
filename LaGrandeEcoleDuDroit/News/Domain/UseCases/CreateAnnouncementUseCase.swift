import Foundation

class CreateAnnouncementUseCase {
    private let announcementLocalRepository: AnnouncementLocalRepository
    private let announcementRemoteRepository: AnnouncementRemoteRepository
    
    init(
        announcementLocalRepository: AnnouncementLocalRepository,
        announcementRemoteRepository: AnnouncementRemoteRepository
    ) {
        self.announcementLocalRepository = announcementLocalRepository
        self.announcementRemoteRepository = announcementRemoteRepository
    }
    
    func execute(announcement: Announcement) async throws {
        var formattedAnnouncement = announcement
        formattedAnnouncement.state = .loading
        formattedAnnouncement.id = UUID().uuidString
        
        do {
            async let localResult: Void = try announcementLocalRepository.insertAnnouncement(announcement: formattedAnnouncement)
            async let remoteResult: Void = try announcementRemoteRepository.createAnnouncement(announcement: formattedAnnouncement)
            
            try await localResult
            try await remoteResult
        } catch {
            var errorAnnouncement = formattedAnnouncement
            errorAnnouncement.state = .error(message: "")
            try await announcementLocalRepository.insertAnnouncement(announcement: errorAnnouncement)
            throw error
        }
    }
}
