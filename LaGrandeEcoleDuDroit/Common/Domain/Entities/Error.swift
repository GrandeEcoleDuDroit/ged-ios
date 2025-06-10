enum NetworkError: Error {
    case internalServer(String?)
    case tooManyRequests
    case dupplicateData
    case forbidden
    case noInternetConnection
    case timeout
    case invalidURL(String)
}

enum UserError: Error {
    case currentUserNotFound
}
