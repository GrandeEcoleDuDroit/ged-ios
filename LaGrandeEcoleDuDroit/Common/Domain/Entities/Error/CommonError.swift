import Foundation

enum CommonError: Error {
    case invalidArgument
}

extension CommonError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .invalidArgument: "Inavlid argument"
        }
    }
}
