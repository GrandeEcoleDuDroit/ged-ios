import Foundation

class ImageRemoteDataSource {
    private let imageApi: ImageApi
    
    init(imageApi: ImageApi) {
        self.imageApi = imageApi
    }
    
    func uploadImage(imageData: Data, imagePath: String) async throws -> (URLResponse, ServerResponse) {
        try await imageApi.uploadImage(imageData: imageData, imagePath: imagePath)
    }
    
    func deleteImage(imagePath: String) async throws -> (URLResponse, ServerResponse) {
        try await imageApi.deleteImage(imagePath: imagePath)
    }
}
