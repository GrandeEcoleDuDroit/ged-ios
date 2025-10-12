import Foundation

class ImageApiImpl: ImageApi {
    private let tokenProvider: TokenProvider
    private let base = "image"
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }

    func uploadImage(imageData: Data, fileName: String) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.getUrl(base: base, endPoint: "upload")
        
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
        if let authIdToken = await tokenProvider.getAuthIdToken() {
            request.setValue("Bearer \(authIdToken)", forHTTPHeaderField: "Authorization")
        }
        
        let session = RequestUtils.getSession()
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func deleteImage(fileName: String) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.getUrl(base: base, endPoint: fileName)
        
        let session = RequestUtils.getSession()
        let authIdToken = await tokenProvider.getAuthIdToken()
        let request = RequestUtils.formatDeleteRequest(
            url: url,
            authToken: authIdToken
        )
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
}
