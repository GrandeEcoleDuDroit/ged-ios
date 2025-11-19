import Foundation

func mapNetworkErrorMessage(
    _ error: Error,
    specificMap: () -> String = { stringResource(.unknownNetworkError) }
) -> String {
    return if let urlError = error as? URLError {
        switch urlError.code {
            case .notConnectedToInternet,
                    .cannotFindHost,
                    .networkConnectionLost: stringResource(.internetConnectionLostError)
            case .cannotConnectToHost: stringResource(.cannotConnectToHostError)
            case .timedOut: stringResource(.timeOutError)
            default: specificMap()
        }
    } else if let networkError = error as? NetworkError {
        switch networkError {
            case .internalServer: stringResource(.internalServerError)
            case .timeout: stringResource(.timeOutError)
            case .noInternetConnection: stringResource(.internetConnectionLostError)
            case .tooManyRequests: stringResource(.tooManyRequestsError)
            default : specificMap()
        }
    } else {
        specificMap()
    }
}
