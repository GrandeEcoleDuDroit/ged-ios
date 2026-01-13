struct ServerError: Error {
    let httpCode: Int
    let message: String
    var errorCode: String? = nil
}
