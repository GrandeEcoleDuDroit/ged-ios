import Foundation

class ImageApiImpl: ImageApi {
    private let tokenProvider: TokenProvider
    private let base = "image"
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
 
    func uploadImage(imageData: Data, imagePath: String) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "upload")
        let session = RequestUtils.getDefaultSession()
        let fileName = imagePath.components(separatedBy: "/").last!
        let fileExtension = (fileName as NSString).pathExtension
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; fileName=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/\(fileExtension)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"imagePath\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(imagePath)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        request.httpBody = body
        if let authToken = await tokenProvider.getAuthToken() {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func deleteImage(imagePath: String) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "delete")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(
            url: url,
            authToken: authToken,
            dataToSend: ["imagePath": imagePath]
        )
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
}
