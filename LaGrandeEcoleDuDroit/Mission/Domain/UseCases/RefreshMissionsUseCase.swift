import Foundation

class RefreshMissionsUseCase {
    private let synchronizeMissionsUseCase: SynchronizeMissionsUseCase
    
    private var lastRequestTime: Int64 = 0
    private let debounceInterval: Int64 = 10000
    
    init(synchronizeMissionsUseCase: SynchronizeMissionsUseCase) {
        self.synchronizeMissionsUseCase = synchronizeMissionsUseCase
    }
    
    func execute() async throws {
        let currentTime = Date().toEpochMilli()
        if currentTime - lastRequestTime > debounceInterval {
            try await synchronizeMissionsUseCase.execute()
            lastRequestTime = currentTime
        }
    }
}
