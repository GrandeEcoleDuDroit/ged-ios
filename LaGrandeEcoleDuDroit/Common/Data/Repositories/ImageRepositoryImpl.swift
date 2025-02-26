import Foundation

class ImageRepositoryImpl: ImageRepository {
    private let imageRemoteDataSource: ImageRemoteDataSource
    
    init(imageRemoteDataSource: ImageRemoteDataSource) {
        self.imageRemoteDataSource = imageRemoteDataSource
    }
    
    func uploadImage(imageData: Data, fileName: String) async throws {
        try await imageRemoteDataSource.uploadImage(imageData: imageData, fileName: fileName)
    }
}
