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
    
    func loadImage(url: String) async throws -> Data? {
        guard let fileName = UrlUtils.getFileNameFromUrl(url: url) else {
            return try await imageRemoteDataSource.downloadImage(url: url)
        }
        var data: Data? = nil
        
        if let localData = imageLocalDataSource.loadImage(forKey: fileName) {
            data = localData
        } else {
            if let remoteData = try await imageRemoteDataSource.downloadImage(url: url) {
                imageLocalDataSource.saveImage(remoteData, forKey: fileName)
                data = remoteData
            }
        }
        
        return data
    }
    
    func uploadImage(imageData: Data, fileName: String) async throws {
        try await mapServerError {
            try await imageRemoteDataSource.uploadImage(
                imageData: imageData,
                fileName: fileName
            )
        }
        imageLocalDataSource.saveImage(imageData, forKey: fileName)
    }
    
    func deleteImage(fileName: String) async throws {
        try await mapServerError {
            try await imageRemoteDataSource.deleteImage(fileName: fileName)
        }
        imageLocalDataSource.removeImage(forKey: fileName)
    }
    
    func clearCache() {
        imageLocalDataSource.clearCache()
    }
}
