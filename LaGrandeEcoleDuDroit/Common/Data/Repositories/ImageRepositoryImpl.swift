import Foundation

class ImageRepositoryImpl: ImageRepository {
    private let imageLocalDataSource: ImageLocalDataSource
    private let imageRemoteDataSource: ImageRemoteDataSource
    private let tag = String(describing: ImageRepositoryImpl.self)
    
    init(
        imageLocalDataSource: ImageLocalDataSource,
        imageRemoteDataSource: ImageRemoteDataSource
    ) {
        self.imageLocalDataSource = imageLocalDataSource
        self.imageRemoteDataSource = imageRemoteDataSource
    }
    
    func createLocalImage(imageData: Data, imagePath: String) async throws {
        try await imageLocalDataSource.createLocalImage(imageData: imageData, imagePath: imagePath)
    }
    
    func uploadImage(imageData: Data, imagePath: String) async throws {
        try await mapServerError(
            block: { try await imageRemoteDataSource.uploadImage(imageData: imageData, imagePath: imagePath) },
            tag: tag,
            message: "Failed to upload remote image: \(imagePath)"
        )
    }
    
    func deleteRemoteImage(imagePath: String) async throws {
        try await mapServerError(
            block: { try await imageRemoteDataSource.deleteImage(imagePath: imagePath) },
            tag: tag,
            message: "Failed to delete remote image: \(imagePath)"
        )
    }
    
    func deleteLocalImage(imagePath: String) async throws {
        try await imageLocalDataSource.deleteLocalImage(imagePath: imagePath)
    }
}
