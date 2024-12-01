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
        let loadingAnnouncement = announcement.copy(state: .loading)
        
        do {
            async let localResult: Void = try announcementLocalRepository.insertAnnouncement(announcement: loadingAnnouncement)
            async let remoteResult: Void = try announcementRemoteRepository.createAnnouncement(announcement: loadingAnnouncement)
            
            try await localResult
            try await remoteResult
            
            let createdAnnouncement = announcement.copy(state: .created)
            try await announcementLocalRepository.updateAnnouncement(announcement: createdAnnouncement)
        } catch {
            let errorAnnouncement = announcement.copy(state: .error(message: error.localizedDescription.description))
            try await announcementLocalRepository.updateAnnouncement(announcement: errorAnnouncement)
            print(error.localizedDescription)
            throw error
        }
    }
}
