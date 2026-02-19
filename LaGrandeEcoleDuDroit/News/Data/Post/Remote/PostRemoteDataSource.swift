class PostRemoteDataSource {
    private let postApi: PostApi
    
    init(postApi: PostApi) {
        self.postApi = postApi
    }
    
    func getPosts() async throws -> [Post] {
        try await postApi.getPosts().map { $0.toPost() }
    }
}
