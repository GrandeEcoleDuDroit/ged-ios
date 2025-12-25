import Foundation

class ImageRepositoryImpl: ImageRepository {
    private let imageLocalDataSource: ImageLocalDataSource
    private let tag = String(describing: ImageRepositoryImpl.self)
    
    init(imageLocalDataSource: ImageLocalDataSource) {
        self.imageLocalDataSource = imageLocalDataSource
    }
    
    func getLocalImage(imagePath: String) async throws -> Data? {
        try await imageLocalDataSource.getImage(imagePath: imagePath)
    }
    
    func createLocalImage(imageData: Data, imagePath: String) async throws {
        try await imageLocalDataSource.createImage(imageData: imageData, imagePath: imagePath)
    }
    
    func deleteLocalImage(imagePath: String) async throws {
        try await imageLocalDataSource.deleteImage(imagePath: imagePath)
    }
}
