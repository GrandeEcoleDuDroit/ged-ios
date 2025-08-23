import Foundation

protocol ImageRepository {
    func loadImage(url: String) async throws -> Data?
    
    func uploadImage(imageData: Data, fileName: String) async throws
    
    func deleteImage(fileName: String) async throws
    
    func clearCache()
}
