struct ServerResponse: Codable {
    var message: String
    var code: String? = nil
    var error: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case message = "message"
        case code = "code"
        case error = "error"
    }
}
