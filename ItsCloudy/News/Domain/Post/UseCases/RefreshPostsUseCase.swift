import Foundation

class RefreshPostsUseCase {
    private let fetchPostsUseCase: FetchPostsUseCase

    private var lastRequestTime: Int64 = 0
    private let debounceInterval: Int64 = 10000
    
    init(fetchPostsUseCase: FetchPostsUseCase) {
        self.fetchPostsUseCase = fetchPostsUseCase
    }
    
    func execute() async throws {
        let currentTime = Date().toEpochMilli()
        if currentTime - lastRequestTime > debounceInterval {
            try await fetchPostsUseCase.execute()
            lastRequestTime = currentTime
        }
    }
}
