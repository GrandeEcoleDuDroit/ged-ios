enum NetworkError: Error {
    case timedOut
    case notConnectedToInternet
    case tooManyRequests
    case unknown
}
