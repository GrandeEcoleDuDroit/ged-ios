struct ServerResponse: Codable {
    let message: String
    let code: String?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case message = "message"
        case code = "code"
        case error = "error"
    }
}
