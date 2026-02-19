protocol PostApi {
    func getPosts() async throws -> [RemotePost]
}
