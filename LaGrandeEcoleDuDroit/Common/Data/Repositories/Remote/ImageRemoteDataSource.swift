import Foundation

class ImageRemoteDataSource {
    private let imageApi: ImageApi
    
    init(imageApi: ImageApi) {
        self.imageApi = imageApi
    }
    
    func uploadImage(imageData: Data, fileName: String) async throws {
        try await imageApi.uploadImage(imageData: imageData, fileName: fileName)
    }
    
    private func formatProfilePictureUrl(fileName: String) -> String {
        "https://objectstorage.eu-paris-1.oraclecloud.com/n/ax5bfuffglob/b/bucket-gedoise/o/\(fileName)"
    }
}
