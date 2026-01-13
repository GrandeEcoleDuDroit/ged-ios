import Foundation

enum NetworkError: Error, Equatable {
    case internalServer(String?)
    case tooManyRequests
    case dupplicateData
    case forbidden
    case unauthorized
    case notConnectedToInternet
    case cannotFindHost
    case networkConnectionLost
    case cannotConnectToHost
    case timedOut
    case badRequest
    case any
    case emptyResponse
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case let .internalServer(message): message ?? stringResource(.internalServerError)
            case .tooManyRequests: stringResource(.tooManyRequestsError)
            case .unauthorized: stringResource(.unauthorizedError)
            case .notConnectedToInternet: stringResource(.internetConnectionLostError)
            case .cannotFindHost: stringResource(.cannotFindHostError)
            case .networkConnectionLost: stringResource(.networkConnectionLostError)
            case .cannotConnectToHost: stringResource(.cannotConnectToHostError)
            case .timedOut: stringResource(.timedOutError)
            case .badRequest: stringResource(.badRequestError)
            case .any: stringResource(.anyNetworkError)
            case .emptyResponse: stringResource(.nilDataError)
            default: stringResource(.unknownError)
        }
    }
}
