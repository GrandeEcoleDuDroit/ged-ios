import Foundation
import FirebaseFirestore

func mapFirebaseError(_ error: Error) -> Error {
    if let urlError = error as? URLError {
        mapUrlError(urlError)
    } else if let errorCode = FirestoreErrorCode.Code(rawValue: (error as NSError).code) {
        switch errorCode {
            case .unknown: CommonError.unknown
            case .permissionDenied: NetworkError.forbidden
            case .resourceExhausted: NetworkError.tooManyRequests
            case .unauthenticated: NetworkError.unauthorized
            default: error
        }
    } else {
        error
    }
}

func mapServerError(_ error: Error) -> Error {
    if let urlError = error as? URLError {
        return mapUrlError(urlError)
    } else if let serverError = error as? ServerError {
        if let errorCode = serverError.errorCode {
            switch errorCode {
                case "ORA-12801": return NetworkError.dupplicateData
                default: break
            }
        }
        
        return switch serverError.httpCode {
            case 400: NetworkError.badRequest
            case 401: NetworkError.unauthorized
            case 403: NetworkError.forbidden
            default: NetworkError.internalServer(serverError.message)
        }
    } else {
        return error
    }
}

private func mapUrlError(_ error: URLError) -> any Error {
    switch error.code {
        case .notConnectedToInternet: NetworkError.notConnectedToInternet
        case .cannotFindHost: NetworkError.cannotFindHost
        case .timedOut: NetworkError.timedOut
        default: error
    }
}
