import Foundation

func mapNetworkErrorMessage(
    _ error: Error,
    specificMap: () -> String = { getString(.unknownNetworkError) }
) -> String {
    return if let urlError = error as? URLError {
        switch urlError.code {
            case .notConnectedToInternet,
                    .cannotFindHost,
                    .networkConnectionLost: getString(.internetConnectionLostError)
            case .cannotConnectToHost: getString(.cannotConnectToHostError)
            case .timedOut: getString(.timeOutError)
            default: specificMap()
        }
    } else if let networkError = error as? NetworkError {
        switch networkError {
            case .internalServer: getString(.internalServerError)
            case .timeout: getString(.timeOutError)
            case .noInternetConnection: getString(.internetConnectionLostError)
            case .tooManyRequests: getString(.tooManyRequestsError)
            default : specificMap()
        }
    } else {
        specificMap()
    }
}
