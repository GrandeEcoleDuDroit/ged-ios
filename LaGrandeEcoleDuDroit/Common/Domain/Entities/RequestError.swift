enum RequestError: Error {
    case invalidURL(String)
    case invalidResponse(String?)
}
