import Foundation

struct AnyError: Error {
    let message: String
}

extension AnyError: LocalizedError {
    var errorDescription: String? {
        message
    }
}
