import Foundation
import Combine

class RefreshAnnouncementsUseCase {
    private let announcementRepository: AnnouncementRepository
    private let networkMonitor: NetworkMonitor
    private var lastRequestTime: Date?
    
    init(
        announcementRepository: AnnouncementRepository,
        networkMonitor: NetworkMonitor
    ) {
        self.announcementRepository = announcementRepository
        self.networkMonitor = networkMonitor
    }
    
    func execute() async throws {
        guard networkMonitor.isConnected else {
            throw NetworkError.noInternetConnection
        }
        
        let currentTime = Date()
        if let lastRequestTime = lastRequestTime {
            let duration = currentTime.timeIntervalSince(lastRequestTime)
            if duration > 10 {
                self.lastRequestTime = currentTime
                try await announcementRepository.refreshAnnouncements()
            }
        } else {
            lastRequestTime = currentTime
            try await announcementRepository.refreshAnnouncements()
        }
        
        if currentTime.timeIntervalSinceNow > -2 {
            try? await Task.sleep(for: .seconds(1))
        }
    }
}
