enum NetworkError: Error, Equatable {
    case internalServer(String?)
    case tooManyRequests
    case dupplicateData
    case forbidden
    case noInternetConnection
    case timeout
    case invalidURL(String)
    case unknown
}

enum UserError: Error {
    case currentUserNotFound
    case userNotFound
}

enum ImageError: Error {
    case invalidFormat
}

enum CommonError: Error {
    case invalidArgument
}
