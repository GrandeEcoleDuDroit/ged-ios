import Foundation

enum CommonError: Error {
    case invalidArgument
    case unknown
}

extension CommonError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .invalidArgument: ""
            case .unknown: stringResource(.unknownError)
        }
    }
}
