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
        var multipartRequest = MultipartRequest()
        
        imageFileData.forEach { fileData in
            multipartRequest.addImage(fileData: fileData)
        }
        try multipartRequest.addJsonValue(name: "post", jsonValue: remotePost)

        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.post.rawValue
        request.httpBody = multipartRequest.body
        request.setValue(multipartRequest.headerValue, forHTTPHeaderField: "Content-Type")
        request.setValue(multipartRequest.body.count.description, forHTTPHeaderField: "Content-Length")
        
        if let authToken = await tokenProvider.getAuthToken() {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func updatePost(remotePost: RemotePost, imageFileData: [FileData]) async throws {
        let url = RequestUtils.getUrl(base: base, endpoint: "/update")
        let session = RequestUtils.getDefaultSession()
        var multipartRequest = MultipartRequest()
        
        imageFileData.forEach { fileData in
            multipartRequest.addImage(fileData: fileData)
        }
        try multipartRequest.addJsonValue(name: "post", jsonValue: remotePost)

        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.post.rawValue
        request.httpBody = multipartRequest.body
        request.setValue(multipartRequest.headerValue, forHTTPHeaderField: "Content-Type")
        request.setValue(multipartRequest.body.count.description, forHTTPHeaderField: "Content-Length")
        
        if let authToken = await tokenProvider.getAuthToken() {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func deletePost(postId: String) async throws {
        let url = RequestUtils.getUrl(base: base, endpoint: "/\(postId)")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.simpleDeleteRequest(url: url, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
}
