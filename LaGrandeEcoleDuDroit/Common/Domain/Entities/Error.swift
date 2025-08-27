enum RequestError: Error, Equatable {
    case internalServer(String?)
    case tooManyRequests
    case dupplicateData
    case forbidden
    case noInternetConnection
    case timeout
    case invalidURL(String)
    case unauthorized
}

enum UserError: Error {
    case currentUserNotFound
}

enum RequestError: Error {
    case unknown(String?)
}
