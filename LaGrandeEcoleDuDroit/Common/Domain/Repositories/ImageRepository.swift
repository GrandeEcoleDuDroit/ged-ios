import Foundation

protocol ImageRepository {
    func getLocalImage(imagePath: String) async throws -> Data?
    
    func createLocalImage(imageData: Data, imagePath: String) async throws
            
    func deleteLocalImage(imagePath: String) async throws
}
