struct ServerResponse: Codable {
    let message: String
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case message = "message"
        case error = "error"
    }
}

