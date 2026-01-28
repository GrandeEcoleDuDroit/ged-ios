import Foundation

struct RequestUtils {
    private init() {}
    
    static func getUrl(base: String, endPoint: String = "") -> URL {
        URL(string: base + endPoint, relativeTo: URL(string: GedConfiguration.serverUrl))!
    }
    
    static func getDefaultSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 20
        return URLSession(configuration: config)
    }
    
    static func simpleGetRequest(
        url: URL,
        authToken: String? = nil
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let authToken {
            request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    static func simplePostRequest(
        url: URL,
        dataToSend: Encodable,
        authToken: String? = nil
    ) throws -> URLRequest {
        try simpleWriteRequest(method: "POST", url: url, authToken: authToken, data: dataToSend)
    }
    
    static func simplePutRequest(
        url: URL,
        dataToSend: Encodable,
        authToken: String? = nil
    ) throws -> URLRequest {
        try simpleWriteRequest(method: "PUT", url: url, authToken: authToken, data: dataToSend)
    }
    
    static func simplePatchRequest(
        url: URL,
        dataToSend: Encodable,
        authToken: String? = nil
    ) throws -> URLRequest {
       try simpleWriteRequest(method: "PATCH", url: url, authToken: authToken, data: dataToSend)
    }
    
    static func simpleDeleteRequest(url: URL, authToken: String? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        if let authToken {
            request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    static func sendRequest(session: URLSession, request: URLRequest) async throws {
        do {
            let (dataReceived, urlResponse) = try await session.data(for: request)
            
            if let httpCode = (urlResponse as? HTTPURLResponse)?.statusCode, httpCode >= 400 {
                if let serverResponse = try? JSONDecoder().decode(ServerResponse.self, from: dataReceived) {
                    throw ServerError(httpCode: httpCode, message: serverResponse.message, errorCode: serverResponse.code)
                } else {
                    let message =  String(bytes: dataReceived, encoding: .utf8)
                    throw ServerError(httpCode: httpCode, message: message.orEmpty())
                }
            }
        } catch {
            throw mapServerError(error)
        }
    }
    
    static func sendDataRequest<T: Decodable>(session: URLSession, request: URLRequest) async throws  -> T? {
        let (dataReceived, urlResponse) = try await session.data(for: request)
        
        if let httpCode = (urlResponse as? HTTPURLResponse)?.statusCode, httpCode >= 400 {
            if let serverResponse = try? JSONDecoder().decode(ServerResponse.self, from: dataReceived) {
                throw ServerError(httpCode: httpCode, message: serverResponse.message, errorCode: serverResponse.code)
            } else {
                let message =  String(bytes: dataReceived, encoding: .utf8)
                throw ServerError(httpCode: httpCode, message: message.orEmpty())
            }
        } else {
            let receivedData = try? JSONDecoder().decode(T.self, from: dataReceived)
            return receivedData
        }
    }
    
    private static func simpleWriteRequest(
        method: String,
        url: URL,
        authToken: String?,
        data: Encodable
    ) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(data)
        if let authToken {
            request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
