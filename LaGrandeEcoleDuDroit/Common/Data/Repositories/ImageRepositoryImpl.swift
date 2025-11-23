import Foundation

class ImageRepositoryImpl: ImageRepository {
    private let imageLocalDataSource: ImageLocalDataSource
    private let imageRemoteDataSource: ImageRemoteDataSource
    
    init(
        imageLocalDataSource: ImageLocalDataSource,
        imageRemoteDataSource: ImageRemoteDataSource
    ) {
        self.imageLocalDataSource = imageLocalDataSource
        self.imageRemoteDataSource = imageRemoteDataSource
    }
    
    func createLocalImage(imageData: Data, fileName: String) async throws {
        try await imageLocalDataSource.createLocalImage(imageData: imageData, fileName: fileName)
    }
    
    func uploadImage(imageData: Data, fileName: String) async throws {
        try await mapServerError {
            try await imageRemoteDataSource.uploadImage(
                imageData: imageData,
                fileName: fileName
            )
        }
    }
    
    func deleteRemoteImage(fileName: String) async throws {
        try await mapServerError {
            try await imageRemoteDataSource.deleteImage(fileName: fileName)
        }
    }
    
    func deleteLocalImage(fileName: String) async throws {
        try await imageLocalDataSource.deleteLocalImage(fileName: fileName)
    }
}
