import Foundation

func withTimeout<T>(_ seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await operation()
        }
        
        group.addTask {
            try await Task.sleep(for: .seconds(seconds))
            throw NetworkError.timeout
        }

        guard let result = try await group.next() else {
            throw CancellationError()
        }

        group.cancelAll()
        return result
    }
}
