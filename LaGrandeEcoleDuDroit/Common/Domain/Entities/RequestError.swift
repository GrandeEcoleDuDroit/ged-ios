enum RequestError: Error {
    case invalidURL
    case invalidResponse(String?)
}
