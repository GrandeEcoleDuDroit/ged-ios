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
    
    func createLocalImage(imageData: Data, folderName: String, fileName: String) async throws -> String? {
        try await imageLocalDataSource.createLocalImage(folderName: folderName, fileName: fileName, imageData: imageData)
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
    
    func deleteLocalImage(folderName: String, fileName: String) async throws {
        try await imageLocalDataSource.deleteLocalImage(folderName:folderName, fileName: fileName)
    }
}
