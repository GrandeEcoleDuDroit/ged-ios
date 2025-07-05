import Foundation

class ImageRemoteDataSource {
    private let imageApi: ImageApi
    
    init(imageApi: ImageApi) {
        self.imageApi = imageApi
    }
    
    func uploadImage(imageData: Data, fileName: String) async throws -> (URLResponse, ServerResponse) {
        try await imageApi.uploadImage(imageData: imageData, fileName: fileName)
    }
    
    func deleteImage(fileName: String) async throws -> (URLResponse, ServerResponse) {
        try await imageApi.deleteImage(fileName: fileName)
    }
}
