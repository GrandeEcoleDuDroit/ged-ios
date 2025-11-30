import Foundation

class RefreshMissionsUseCase {
    private let fetchMissionsUseCase: FetchMissionsUseCase
    
    private var lastRequestTime: Int64 = 0
    private let debounceInterval: Int64 = 10000
    
    init(fetchMissionsUseCase: FetchMissionsUseCase) {
        self.fetchMissionsUseCase = fetchMissionsUseCase
    }
    
    func execute() async throws {
        let currentTime = Date().toEpochMilli()
        if currentTime - lastRequestTime > debounceInterval {
            try await fetchMissionsUseCase.execute()
            lastRequestTime = currentTime
        }
    }
}
