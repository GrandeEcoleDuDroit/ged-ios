import Foundation

class ImageRepositoryImpl: ImageRepository {
    private let imageLocalDataSource: ImageLocalDataSource
    private let tag = String(describing: ImageRepositoryImpl.self)
    
    init(imageLocalDataSource: ImageLocalDataSource) {
        self.imageLocalDataSource = imageLocalDataSource
    }
    
    func getLocalImage(imagePath: String) async throws -> Data? {
        do {
            return try await imageLocalDataSource.getImage(imagePath: imagePath)
        } catch {
            e(tag, "Error getting local image", error)
            throw error
        }
    }
    
    func createLocalImage(imageData: Data, imagePath: String) async throws {
        do {
            try await imageLocalDataSource.createImage(imageData: imageData, imagePath: imagePath)
        } catch {
            e(tag, "Error creating local image", error)
            throw error
        }
    }
    
    func deleteLocalImage(imagePath: String) async throws {
        do {
            try await imageLocalDataSource.deleteImage(imagePath: imagePath)
        } catch {
            e(tag, "Error deleting local image", error)
            throw error
        }
    }
}
