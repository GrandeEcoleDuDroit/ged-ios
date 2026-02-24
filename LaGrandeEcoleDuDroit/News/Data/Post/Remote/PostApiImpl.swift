import Foundation

class PostApiImpl: PostApi {
    private let tokenProvider: TokenProvider
    private let base = "/posts"

    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func getPosts() async throws -> [RemotePost] {
        let url = RequestUtils.getUrl(base: base)
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.simpleGetRequest(url: url, authToken: authToken)
        
        if let missions: [RemotePost] = try await RequestUtils.sendDataRequest(session: session, request: request) {
            return missions
        } else {
            throw NetworkError.unknown
        }
    }
    
    func createPost(remotePost: RemotePost, imageFileData: [FileData]) async throws {
        let url = RequestUtils.getUrl(base: base, endpoint: "/create")
        let session = RequestUtils.getDefaultSession()
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        imageFileData.forEach { fileData in
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileData.name)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/\(fileData.fileExtension)\r\n\r\n".data(using: .utf8)!)
            body.append(fileData.data)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"post\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
        body.append(try JSONEncoder().encode(remotePost))
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        
        if let authToken = await tokenProvider.getAuthToken() {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
}
