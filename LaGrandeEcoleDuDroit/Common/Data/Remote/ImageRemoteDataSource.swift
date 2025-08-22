import Foundation

class ImageRemoteDataSource {
    private let imageApi: ImageApi
    
    init(imageApi: ImageApi) {
        self.imageApi = imageApi
    }
    
    func downloadImage(url: String) async throws -> Data? {
       try await imageApi.downloadImage(url: url)
   }
    
    func uploadImage(imageData: Data, fileName: String) async throws -> (URLResponse, ServerResponse) {
        try await imageApi.uploadImage(imageData: imageData, fileName: fileName)
    }
    
    func deleteImage(fileName: String) async throws -> (URLResponse, ServerResponse) {
        try await imageApi.deleteImage(fileName: fileName)
    }
}
