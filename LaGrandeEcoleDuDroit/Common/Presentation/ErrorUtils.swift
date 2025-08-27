import Foundation

func mapNetworkErrorMessage(
    _ error: Error,
    specificMap: () -> String = { getString(.unknownNetworkError) }
) -> String {
    return if let urlError = error as? URLError {
        switch urlError.code {
            case .notConnectedToInternet,
                    .cannotFindHost,
                    .networkConnectionLost: getString(.noInternetConectionError)
            case .timedOut: getString(.timeOutError)
            default: specificMap()
        }
    } else if let networkError = error as? RequestError {
        switch networkError {
            case .internalServer: getString(.internalServerError)
            case .timeout: getString(.timeOutError)
            case .noInternetConnection: getString(.noInternetConectionError)
            case .tooManyRequests: getString(.tooManyRequestsError)
            default : specificMap()
        }
    } else {
        specificMap()
    }
}
