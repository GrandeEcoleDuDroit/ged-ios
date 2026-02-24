import Foundation

protocol PostApi {
    func getPosts() async throws -> [RemotePost]
    
    func createPost(remotePost: RemotePost, imageFileData: [FileData]) async throws
}
