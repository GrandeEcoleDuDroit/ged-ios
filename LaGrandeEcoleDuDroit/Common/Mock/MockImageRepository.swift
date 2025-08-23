import Foundation

class MockImageRepository: ImageRepository {
    func loadImage(url: String) async throws -> Data? { nil }
    
    func uploadImage(imageData: Data, fileName: String) async throws {}
    
    func deleteImage(fileName: String) async throws {}
    
    func clearCache() {}
}
