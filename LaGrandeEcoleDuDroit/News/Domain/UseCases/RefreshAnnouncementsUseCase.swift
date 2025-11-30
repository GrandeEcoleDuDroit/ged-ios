import Foundation

class RefreshAnnouncementsUseCase {
    private let fetchAnnouncementsUseCase: FetchAnnouncementsUseCase
    
    private var lastRequestTime: Int64 = 0
    private let debounceInterval: Int64 = 10000
    
    init(fetchAnnouncementsUseCase: FetchAnnouncementsUseCase) {
        self.fetchAnnouncementsUseCase = fetchAnnouncementsUseCase
    }
    
    func execute() async throws {
        let currentTime = Date().toEpochMilli()
        if currentTime - lastRequestTime > debounceInterval {
            try await fetchAnnouncementsUseCase.execute()
            lastRequestTime = currentTime
        }
    }
}
