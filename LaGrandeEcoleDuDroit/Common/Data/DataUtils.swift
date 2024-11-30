import Foundation

class DataUtils {
    static func getUrlSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        config.timeoutIntervalForResource = 20.0
        return URLSession(configuration: config)
    }
    
    static func formatPostRequest(dataToSend: Encodable, url: URL) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(dataToSend)
        
        return request
    }
}
