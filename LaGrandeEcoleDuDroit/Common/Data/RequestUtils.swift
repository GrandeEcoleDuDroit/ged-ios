import Foundation

class RequestUtils {
    static func getUrlSession() -> URLSession {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }
    
    static func formatPostRequest(dataToSend: Encodable, url: URL) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(dataToSend)
        
        return request
    }
    
    static func formatPutRequest(dataToSend: Encodable, url: URL) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(dataToSend)
        
        return request
    }
    
    static func formatDeleteRequest(url: URL) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        return request
    }
}
