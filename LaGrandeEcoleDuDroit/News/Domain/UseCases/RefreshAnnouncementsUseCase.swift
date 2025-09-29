import Foundation
import Combine

class RefreshAnnouncementsUseCase {
    private let synchronizeAnnouncementsUseCase: SynchronizeAnnouncementsUseCase
    
    private var lastRequestTime: Int64 = 0
    private let tag = String(describing: RefreshAnnouncementsUseCase.self)
    private let debounceInterval: Int64 = 10000
    
    init(synchronizeAnnouncementsUseCase: SynchronizeAnnouncementsUseCase) {
        self.synchronizeAnnouncementsUseCase = synchronizeAnnouncementsUseCase
    }
    
    func execute() async throws {
        let currentTime = Date().toEpochMilli()
        if currentTime - lastRequestTime > debounceInterval {
            try await synchronizeAnnouncementsUseCase.execute()
            lastRequestTime = currentTime
        }
    }
}
