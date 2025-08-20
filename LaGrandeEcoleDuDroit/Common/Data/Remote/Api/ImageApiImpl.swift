import Foundation

class ImageApiImpl: ImageApi {
    private let tokenProvider: TokenProvider
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }

    private func baseUrl(endPoint: String) -> URL? {
        URL.oracleUrl(endpoint: "/image/" + endPoint)
    }
    
    func uploadImage(imageData: Data, fileName: String) async throws -> (URLResponse, ServerResponse) {
        guard let url = baseUrl(endPoint: "upload") else {
            throw NetworkError.invalidURL("Invalid URL")
        }
        
        let fileExtension = (fileName as NSString).pathExtension
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/\(fileExtension)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        request.httpBody = body
        if let authIdToken = tokenProvider.getAuthIdToken() {
            request.setValue("Bearer \(authIdToken)", forHTTPHeaderField: "Authorization")
        }
        
        let session = RequestUtils.getUrlSession()
        let (dataReceived, urlResponse) = try await session.data(for: request)
        let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: dataReceived)
        
        return (urlResponse, serverResponse)
    }
    
    func deleteImage(fileName: String) async throws -> (URLResponse, ServerResponse) {
        guard let url = baseUrl(endPoint: "/\(fileName)") else {
            throw NetworkError.invalidURL("Invalid URL")
        }
        
        let sessions = RequestUtils.getUrlSession()
        let deleteRequest = try RequestUtils.formatDeleteRequest(url: url, authToken: tokenProvider.getAuthIdToken())
        
        let (data, urlResponse) = try await sessions.data(for: deleteRequest)
        let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: data)
        return (urlResponse, serverResponse)
    }
}
