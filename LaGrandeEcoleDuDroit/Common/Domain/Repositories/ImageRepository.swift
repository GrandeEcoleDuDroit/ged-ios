import Foundation

protocol ImageRepository {
    func uploadImage(imageData: Data, fileName: String) async throws
    
    func deleteImage(fileName: String) async throws
}
