import Foundation

func withTimeout<T>(_ seconds: TimeInterval, block: @escaping () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await block()
        }
        
        group.addTask {
            try await Task.sleep(for: .seconds(seconds))
            throw NetworkError.timedOut
        }

        guard let result = try await group.next() else {
            throw CancellationError()
        }

        group.cancelAll()
        return result
    }
}
