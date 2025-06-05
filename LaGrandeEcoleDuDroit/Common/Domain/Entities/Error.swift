enum NetworkError: Error {
    case internalServer
    case tooManyRequests
    case dupplicateData
    case forbidden
    case noInternetConnection
    case timeout
}

enum UserError: Error {
    case currentUserNotFound
}

enum RequestError: Error {
    case invalidURL(String)
    case invalidResponse(String?)
}
